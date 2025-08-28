import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class BootstrapStreamingExecutableTests: XCTestCase, URLSessionDataDelegate {
    private var received = Data()
    private var expectation: XCTestExpectation?

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        received.append(data)
        if let text = String(data: received, encoding: .utf8), text.contains("event: drift") {
            expectation?.fulfill()
        }
    }

    func testStreamingEmitsDriftAndHeartbeatOrSkips() async throws {
        // Find bootstrap-server binary
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let exec = findExecutable(named: "bootstrap-server", under: root.appendingPathComponent(".build")) else {
            throw XCTSkip("bootstrap-server executable not found; skipping streaming test")
        }
        // Skip if port 8082 is busy
        if isPortOpen(8082) { throw XCTSkip("port 8082 in use; skipping") }

        // Launch server
        let proc = Process()
        proc.executableURL = exec
        let pipe = Pipe(); proc.standardOutput = pipe; proc.standardError = pipe
        try proc.run()
        // Small wait for server to bind
        try await Task.sleep(nanoseconds: 300_000_000)

        // Stream SSE and assert we get first event quickly
        expectation = expectation(description: "received drift event")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        var req = URLRequest(url: URL(string: "http://127.0.0.1:8082/bootstrap/baseline?sse=1")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["corpusId": "sse-x", "baselineId": "b1", "content": "x"]) 
        let task = session.dataTask(with: req)
        task.resume()
        wait(for: [expectation!], timeout: 2.0)
        expectation = expectation(description: "received heartbeat event")
        wait(for: [expectation!], timeout: 2.0)

        task.cancel()
        session.invalidateAndCancel()
        proc.terminate()
    }

    private func findExecutable(named: String, under dir: URL) -> URL? {
        let fm = FileManager.default
        guard let e = fm.enumerator(at: dir, includingPropertiesForKeys: nil) else { return nil }
        for case let url as URL in e {
            if url.lastPathComponent == named && (try? url.resourceValues(forKeys: [.isExecutableKey]).isExecutable) == true {
                return url
            }
        }
        return nil
    }

    private func isPortOpen(_ port: Int32) -> Bool {
        var hints = addrinfo(ai_flags: AI_PASSIVE, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM, ai_protocol: 0,
                             ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
        var res: UnsafeMutablePointer<addrinfo>? = nil
        getaddrinfo("127.0.0.1", String(port), &hints, &res)
        defer { if res != nil { freeaddrinfo(res) } }
        guard let ai = res else { return false }
        let fd = socket(ai.pointee.ai_family, ai.pointee.ai_socktype, ai.pointee.ai_protocol)
        defer { if fd >= 0 { close(fd) } }
        let result = connect(fd, ai.pointee.ai_addr, ai.pointee.ai_addrlen)
        return result == 0
    }
}


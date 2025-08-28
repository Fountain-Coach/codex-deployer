import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class GatewayAwarenessSSEProxyStreamingTests: XCTestCase, URLSessionDataDelegate {
    private var received = Data()
    private var expectation: XCTestExpectation?
    private var sawTick = false

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        received.append(data)
        if let text = String(data: received, encoding: .utf8) {
            if !sawTick, text.contains("event: tick") {
                sawTick = true
                expectation?.fulfill()
            } else if sawTick, text.contains("heartbeat") {
                expectation?.fulfill()
            }
        }
    }

    @MainActor
    func testAwarenessSSEProxiedHeartbeatOrSkips() async throws {
        // Locate baseline-awareness-server executable
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let exec = findExecutable(named: "baseline-awareness-server", under: root.appendingPathComponent(".build")) else {
            throw XCTSkip("baseline-awareness-server executable not found; skipping")
        }
        // Check ports
        if isPortOpen(8081) || isPortOpen(9141) { throw XCTSkip("required port busy; skipping") }

        // Start awareness upstream
        let proc = Process()
        proc.executableURL = exec
        let pipe = Pipe(); proc.standardOutput = pipe; proc.standardError = pipe
        try proc.run()
        try await Task.sleep(nanoseconds: 300_000_000)

        // Gateway route config
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let routes = [Route(id: "awareness", path: "/awareness", target: "http://127.0.0.1:8081", methods: ["GET"], rateLimit: nil, proxyEnabled: true)]
        try JSONEncoder().encode(routes).write(to: file)

        // Start gateway
        let server = GatewayServer(plugins: [], zoneManager: nil, routeStoreURL: file)
        let port = 9141
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Stream SSE through gateway to awareness
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var req = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/awareness/corpus/history/stream?sse=1")!)
        req.httpMethod = "GET"
        expectation = expectation(description: "received tick via gateway")
        let task = session.dataTask(with: req)
        task.resume()
        wait(for: [expectation!], timeout: 2.5)
        expectation = expectation(description: "received heartbeat via gateway")
        wait(for: [expectation!], timeout: 2.5)

        task.cancel(); session.invalidateAndCancel()
        try await server.stop(); proc.terminate()
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


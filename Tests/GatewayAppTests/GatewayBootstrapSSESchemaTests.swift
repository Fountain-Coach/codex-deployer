import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Yams
@testable import gateway_server

final class GatewayBootstrapSSESchemaTests: XCTestCase, URLSessionDataDelegate {
    private var received = Data()
    private var expectation: XCTestExpectation?
    private var sawDrift = false
    private var sawPatterns = false

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        received.append(data)
        if let text = String(data: received, encoding: .utf8) {
            var lastEvent: String?
            for raw in text.split(separator: "\n", omittingEmptySubsequences: false) {
                let line = String(raw)
                if line.hasPrefix("event:") {
                    lastEvent = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                } else if line.hasPrefix("data:") {
                    let payload = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                    if let d = payload.data(using: .utf8),
                       let obj = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                        if lastEvent == "drift" && !sawDrift, (obj["status"] as? String) == "started" { sawDrift = true; expectation?.fulfill() }
                        if lastEvent == "patterns" && !sawPatterns, (obj["status"] as? String) == "started" { sawPatterns = true; expectation?.fulfill() }
                    }
                }
            }
        }
    }

    @MainActor
    func testBootstrapSSEDataMatchesSchemasOrSkips() async throws {
        // Locate bootstrap-server executable
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let exec = findExecutable(named: "bootstrap-server", under: root.appendingPathComponent(".build")) else {
            throw XCTSkip("bootstrap-server executable not found; skipping")
        }
        if isPortOpen(8082) || isPortOpen(9135) { throw XCTSkip("required port busy; skipping") }

        // Start bootstrap upstream
        let proc = Process(); proc.executableURL = exec
        let pipe = Pipe(); proc.standardOutput = pipe; proc.standardError = pipe
        try proc.run(); try await Task.sleep(nanoseconds: 300_000_000)

        // Gateway routes
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let routes = [Route(id: "bootstrap", path: "/bootstrap", target: "http://127.0.0.1:8082", methods: ["GET","POST"], rateLimit: nil, proxyEnabled: true)]
        try JSONEncoder().encode(routes).write(to: file)

        // Start gateway
        let server = GatewayServer(plugins: [], zoneManager: nil, routeStoreURL: file)
        let port = 9135
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Start stream
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var req = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/bootstrap/baseline?sse=1")!)
        req.httpMethod = "POST"; req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["corpusId": "pgw", "baselineId": "b1", "content": "x"]) 
        expectation = expectation(description: "received drift and patterns")
        expectation?.expectedFulfillmentCount = 2
        let task = session.dataTask(with: req)
        task.resume()
        wait(for: [expectation!], timeout: 3.0)

        // Validate against bootstrap schemas
        let text = try String(contentsOfFile: "openapi/v1/bootstrap.yml")
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let schemas = (yaml?["components"] as? [String: Any])?["schemas"] as? [String: Any]
        let driftSchema = (schemas?["StreamDriftData"] as? [String: Any]) ?? [:]
        let patternsSchema = (schemas?["StreamPatternsData"] as? [String: Any]) ?? [:]
        if let s = String(data: received, encoding: .utf8) {
            var lastEvent: String?
            for raw in s.split(separator: "\n") {
                let line = String(raw)
                if line.hasPrefix("event:") { lastEvent = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces) }
                else if line.hasPrefix("data:") {
                    let payload = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                    if let d = payload.data(using: .utf8), let obj = try? JSONSerialization.jsonObject(with: d) {
                        if lastEvent == "drift" { XCTAssertTrue(LocalSchemaValidator.validate(obj, driftSchema)) }
                        if lastEvent == "patterns" { XCTAssertTrue(LocalSchemaValidator.validate(obj, patternsSchema)) }
                    }
                }
            }
        }

        task.cancel(); session.invalidateAndCancel()
        try await server.stop(); proc.terminate()
    }

    private func findExecutable(named: String, under dir: URL) -> URL? {
        let fm = FileManager.default
        guard let e = fm.enumerator(at: dir, includingPropertiesForKeys: nil) else { return nil }
        for case let url as URL in e {
            if url.lastPathComponent == named && (try? url.resourceValues(forKeys: [.isExecutableKey]).isExecutable) == true { return url }
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

// reuse the local validator from GatewayAwarenessSSEProxyStreamingTests.swift
struct LocalSchemaValidator {
    enum T: String { case object, string }
    static func validate(_ obj: Any, _ schema: [String: Any]) -> Bool {
        guard let t = schema["type"] as? String, let ty = T(rawValue: t) else { return true }
        switch ty {
        case .object:
            guard let o = obj as? [String: Any] else { return false }
            let req = schema["required"] as? [String] ?? []
            for k in req { if o[k] == nil { return false } }
            return true
        case .string:
            return obj is String
        }
    }
}


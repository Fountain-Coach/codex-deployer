import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class CircuitBreakerStateTests: XCTestCase {
    @MainActor
    func testCircuitBreakerOpensAndRejects() async throws {
        setenv("GATEWAY_CB_FAILURES", "1", 1)
        setenv("GATEWAY_CB_RESET_SECS", "100", 1)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let routes = [Route(id: "bad", path: "/bad", target: "http://127.0.0.1:1", methods: ["GET"], rateLimit: nil, proxyEnabled: true)]
        try JSONEncoder().encode(routes).write(to: file)

        let server = GatewayServer(plugins: [], zoneManager: nil, routeStoreURL: file)
        let port = 9153
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        func metrics() async throws -> [String: Int] {
            let url = URL(string: "http://127.0.0.1:\(port)/metrics")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return (try JSONSerialization.jsonObject(with: data) as? [String: Int]) ?? [:]
        }

        let m0 = try await metrics()
        let base502 = m0["gateway_responses_status_502_total"] ?? 0
        let base503 = m0["gateway_responses_status_503_total"] ?? 0
        let baseOpens = m0["gateway_cb_opens_total"] ?? 0
        let baseRejects = m0["gateway_cb_rejects_total"] ?? 0

        let url = URL(string: "http://127.0.0.1:\(port)/bad")!

        // First call triggers failure -> 502 and open
        let (_, r1) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 502)
        var m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_502_total"] ?? 0, base502 + 1)
        XCTAssertEqual(m1["gateway_cb_opens_total"] ?? 0, baseOpens + 1)

        // Second call rejected -> 503
        let (_, r2) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 503)
        m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_503_total"] ?? 0, base503 + 1)
        XCTAssertEqual(m1["gateway_cb_rejects_total"] ?? 0, baseRejects + 1)

        try await server.stop()
        unsetenv("GATEWAY_CB_FAILURES")
        unsetenv("GATEWAY_CB_RESET_SECS")
    }
}


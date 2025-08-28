import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class RouteCrudFailureTests: XCTestCase {
    @MainActor
    func testRouteCrudFailuresRecordMetrics() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        try Data("[]".utf8).write(to: file)

        let server = GatewayServer(plugins: [], zoneManager: nil, routeStoreURL: file)
        let port = 9150
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        func metrics() async throws -> [String: Int] {
            let url = URL(string: "http://127.0.0.1:\(port)/metrics")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return (try JSONSerialization.jsonObject(with: data) as? [String: Int]) ?? [:]
        }

        let m0 = try await metrics()
        let base400 = m0["gateway_responses_status_400_total"] ?? 0
        let base404 = m0["gateway_responses_status_404_total"] ?? 0

        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        // Create with invalid method -> 400
        let badRoute = Route(id: "r1", path: "/x", target: "http://example", methods: ["BAD"], rateLimit: nil, proxyEnabled: true)
        var create = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/routes")!)
        create.httpMethod = "POST"
        create.setValue("application/json", forHTTPHeaderField: "Content-Type")
        create.httpBody = try JSONEncoder().encode(badRoute)
        let (_, r1) = try await URLSession.shared.data(for: create)
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 400)
        var m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_400_total"] ?? 0, base400 + 1)

        // Update nonexistent -> 404
        let upd = Route(id: "nope", path: "/x", target: "http://example", methods: ["GET"], rateLimit: nil, proxyEnabled: true)
        var update = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/routes/nope")!)
        update.httpMethod = "PUT"
        update.setValue("application/json", forHTTPHeaderField: "Content-Type")
        update.httpBody = try JSONEncoder().encode(upd)
        let (_, r2) = try await URLSession.shared.data(for: update)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 404)
        m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_404_total"] ?? 0, base404 + 1)

        // Delete nonexistent -> 404
        var del = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/routes/nope")!)
        del.httpMethod = "DELETE"
        let (_, r3) = try await URLSession.shared.data(for: del)
        XCTAssertEqual((r3 as? HTTPURLResponse)?.statusCode, 404)
        let m2 = try await metrics()
        XCTAssertEqual(m2["gateway_responses_status_404_total"] ?? 0, base404 + 2)

        try await server.stop()
    }
}


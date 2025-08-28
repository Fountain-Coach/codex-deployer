import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class RoleGuardMetricsExposureTests: XCTestCase {
    @MainActor
    func testMetricsIncludeRoleGuardCounters() async throws {
        let store = RoleGuardStore(initialRules: [:], configURL: nil)
        let server = GatewayServer(plugins: [], roleGuardStore: store)
        let port = 9147
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Trigger 401 on admin-protected endpoint to increment unauthorized counter
        let adminURL = URL(string: "http://127.0.0.1:\(port)/roleguard")!
        let (_, r1) = try await URLSession.shared.data(from: adminURL)
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 401)

        // Read metrics
        let metricsURL = URL(string: "http://127.0.0.1:\(port)/metrics")!
        let (data, r2) = try await URLSession.shared.data(from: metricsURL)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 200)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let unauthorized = obj?["roleguard_unauthorized_total"] as? Int ?? -1
        XCTAssertGreaterThanOrEqual(unauthorized, 1)

        try await server.stop()
    }
}


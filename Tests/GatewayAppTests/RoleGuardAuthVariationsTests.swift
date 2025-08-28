import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class RoleGuardAuthVariationsTests: XCTestCase {
    @MainActor
    func testAuthResponsesAndMetrics() async throws {
        let store = RoleGuardStore(initialRules: [:], configURL: nil)
        let server = GatewayServer(plugins: [], roleGuardStore: store)
        let port = 9151
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        func metrics() async throws -> [String: Int] {
            let url = URL(string: "http://127.0.0.1:\(port)/metrics")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return (try JSONSerialization.jsonObject(with: data) as? [String: Int]) ?? [:]
        }

        let m0 = try await metrics()
        let base401 = m0["gateway_responses_status_401_total"] ?? 0
        let base403 = m0["gateway_responses_status_403_total"] ?? 0
        let base200 = m0["gateway_responses_status_200_total"] ?? 0
        let baseUnauth = m0["roleguard_unauthorized_total"] ?? 0
        let baseForbidden = m0["roleguard_forbidden_total"] ?? 0

        let url = URL(string: "http://127.0.0.1:\(port)/roleguard")!

        // No token
        let (_, r1) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 401)
        var m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_401_total"] ?? 0, base401 + 1)
        XCTAssertEqual(m1["roleguard_unauthorized_total"] ?? 0, baseUnauth + 1)

        // User token -> 403
        let credStore = CredentialStore()
        var req = URLRequest(url: url)
        let user = try credStore.signJWT(subject: "c", expiresAt: Date().addingTimeInterval(3600), role: "user")
        req.setValue("Bearer \(user)", forHTTPHeaderField: "Authorization")
        let (_, r2) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 403)
        m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_403_total"] ?? 0, base403 + 1)
        XCTAssertEqual(m1["roleguard_forbidden_total"] ?? 0, baseForbidden + 1)

        // Admin token -> 200
        let admin = try credStore.signJWT(subject: "c", expiresAt: Date().addingTimeInterval(3600), role: "admin")
        req.setValue("Bearer \(admin)", forHTTPHeaderField: "Authorization")
        let (_, r3) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((r3 as? HTTPURLResponse)?.statusCode, 200)
        let m2 = try await metrics()
        XCTAssertEqual(m2["gateway_responses_status_200_total"] ?? 0, base200 + 1)

        try await server.stop()
    }
}


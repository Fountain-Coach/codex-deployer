import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class RoleGuardAdminEndpointsTests: XCTestCase {
    @MainActor
    func testAdminEndpointsRequireAdmin() async throws {
        let store = RoleGuardStore(initialRules: [:], configURL: nil)
        let server = GatewayServer(plugins: [], roleGuardStore: store)
        let port = 9146
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // 401 without token
        let url = URL(string: "http://127.0.0.1:\(port)/roleguard")!
        let (_, r1) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 401)

        // 403 with non-admin token
        var req = URLRequest(url: url)
        let storeCreds = CredentialStore()
        let user = try storeCreds.signJWT(subject: "c", expiresAt: Date().addingTimeInterval(3600), role: "user")
        req.setValue("Bearer \(user)", forHTTPHeaderField: "Authorization")
        let (_, r2) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 403)

        // 200 with admin token
        let admin = try storeCreds.signJWT(subject: "c", expiresAt: Date().addingTimeInterval(3600), role: "admin")
        req.setValue("Bearer \(admin)", forHTTPHeaderField: "Authorization")
        let (_, r3) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((r3 as? HTTPURLResponse)?.statusCode, 200)

        try await server.stop()
    }
}


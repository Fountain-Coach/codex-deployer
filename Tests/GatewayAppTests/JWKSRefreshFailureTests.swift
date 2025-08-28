import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

final class JWKSRefreshFailureTests: XCTestCase {
    @MainActor
    func testJWKSRefreshFailureIncrements401Metric() async throws {
        setenv("GATEWAY_JWKS_URL", "http://127.0.0.1:0/jwks", 1)
        let server = GatewayServer(plugins: [])
        let port = 9150
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        let before = await GatewayRequestMetrics.shared.snapshot()

        let store = CredentialStore()
        let token = try store.signJWT(subject: "admin", expiresAt: Date().addingTimeInterval(3600), role: "admin")
        var req = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/routes")!)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, resp) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 401)

        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_401_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)

        try await server.stop()
        unsetenv("GATEWAY_JWKS_URL")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import Foundation
@testable import AuthGatewayPlugin
import FountainRuntime
import gateway_server

final class AuthGatewayPluginTests: XCTestCase {
    func testValidationAndClaims() async throws {
        setenv("GATEWAY_JWT_SECRET", "topsecret", 1)
        let store = CredentialStore()
        let token = try store.signJWT(subject: "admin", expiresAt: Date().addingTimeInterval(3600), role: "admin")
        let plugin = AuthGatewayPlugin()
        let body = ValidateRequest(token: token)
        let data = try JSONEncoder().encode(body)
        let validateReq = HTTPRequest(method: "POST", path: "/auth/validate", body: data)
        let validateResp = try await plugin.router.route(validateReq)
        XCTAssertEqual(validateResp?.status, 200)

        let claimsReq = HTTPRequest(method: "GET", path: "/auth/claims", headers: ["Authorization": "Bearer \(token)"])
        let claimsResp = try await plugin.router.route(claimsReq)
        XCTAssertEqual(claimsResp?.status, 200)
    }

    @MainActor
    func testInvalidTokenReturns401AndMetrics() async throws {
        setenv("GATEWAY_JWT_SECRET", "topsecret", 1)
        let plugin = AuthGatewayPlugin()
        let server = GatewayServer(plugins: [plugin])
        let port = 9148
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        let before = await GatewayRequestMetrics.shared.snapshot()

        var req = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/auth/validate")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ValidateRequest(token: "badtoken")
        req.httpBody = try JSONEncoder().encode(body)
        let (_, resp) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 401)

        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_401_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)

        try await server.stop()
    }

    @MainActor
    func testMissingTokenReturns401AndMetrics() async throws {
        let plugin = AuthGatewayPlugin()
        let server = GatewayServer(plugins: [plugin])
        let port = 9149
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        let before = await GatewayRequestMetrics.shared.snapshot()

        let url = URL(string: "http://127.0.0.1:\(port)/auth/claims")!
        let (_, resp) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 401)

        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_401_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)

        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

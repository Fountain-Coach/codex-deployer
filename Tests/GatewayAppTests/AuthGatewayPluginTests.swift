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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

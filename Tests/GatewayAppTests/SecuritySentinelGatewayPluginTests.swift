import XCTest
import Foundation
@testable import SecuritySentinelGatewayPlugin
import FountainRuntime
import gateway_server

final class SecuritySentinelGatewayPluginTests: XCTestCase {
    @MainActor
    func testDenyDecisionAndMetrics() async throws {
        let plugin = SecuritySentinelGatewayPlugin()
        let body = SecurityCheckRequest(summary: "delete files", user: "u", resources: [])
        let data = try JSONEncoder().encode(body)
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult", body: data)
        let resp = try await plugin.router.route(request)
        let decision = try JSONDecoder().decode(SecurityDecision.self, from: resp!.body)
        XCTAssertEqual(decision.decision, "deny")
        let before = await GatewayRequestMetrics.shared.snapshot()
        await GatewayRequestMetrics.shared.record(method: request.method, status: resp!.status)
        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_200_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)
    }

    @MainActor
    func testAllowDecisionAndMetrics() async throws {
        let plugin = SecuritySentinelGatewayPlugin()
        let body = SecurityCheckRequest(summary: "safe", user: "u", resources: [])
        let data = try JSONEncoder().encode(body)
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult", body: data)
        let resp = try await plugin.router.route(request)
        let decision = try JSONDecoder().decode(SecurityDecision.self, from: resp!.body)
        XCTAssertEqual(decision.decision, "allow")
        let before = await GatewayRequestMetrics.shared.snapshot()
        await GatewayRequestMetrics.shared.record(method: request.method, status: resp!.status)
        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_200_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

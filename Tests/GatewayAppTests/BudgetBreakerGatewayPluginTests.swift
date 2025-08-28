import XCTest
import Foundation
@testable import BudgetBreakerGatewayPlugin
import FountainRuntime
import gateway_server

final class BudgetBreakerGatewayPluginTests: XCTestCase {
    @MainActor
    func testBudgetCheckAllowsAndMetrics() async throws {
        let plugin = BudgetBreakerGatewayPlugin()
        let body = BudgetCheckRequest(routeId: "r1", clientId: "c1", amount: 1)
        let data = try JSONEncoder().encode(body)
        let request = HTTPRequest(method: "POST", path: "/budget/check", body: data)
        let resp = try await plugin.router.route(request)
        XCTAssertEqual(resp?.status, 200)
        let before = await GatewayRequestMetrics.shared.snapshot()
        await GatewayRequestMetrics.shared.record(method: request.method, status: resp!.status)
        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_200_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)
    }

    @MainActor
    func testBudgetCheckMissingBodyReturns400AndMetrics() async throws {
        let plugin = BudgetBreakerGatewayPlugin()
        let request = HTTPRequest(method: "POST", path: "/budget/check", body: Data())
        let resp = try await plugin.router.route(request)
        XCTAssertEqual(resp?.status, 400)
        let before = await GatewayRequestMetrics.shared.snapshot()
        await GatewayRequestMetrics.shared.record(method: request.method, status: resp!.status)
        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_400_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

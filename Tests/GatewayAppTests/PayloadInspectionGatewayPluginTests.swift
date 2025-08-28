import XCTest
import Foundation
@testable import PayloadInspectionGatewayPlugin
import FountainRuntime
import gateway_server

final class PayloadInspectionGatewayPluginTests: XCTestCase {
    @MainActor
    func testInspectReturnsPayloadAndMetrics() async throws {
        let plugin = PayloadInspectionGatewayPlugin()
        let body = PayloadInspectionRequest(payload: "data")
        let data = try JSONEncoder().encode(body)
        let request = HTTPRequest(method: "POST", path: "/inspect", body: data)
        let resp = try await plugin.router.route(request)
        let inspected = try JSONDecoder().decode(PayloadInspectionResponse.self, from: resp!.body)
        XCTAssertEqual(inspected.sanitized, "data")
        let before = await GatewayRequestMetrics.shared.snapshot()
        await GatewayRequestMetrics.shared.record(method: request.method, status: resp!.status)
        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_200_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)
    }

    @MainActor
    func testInspectMissingBodyReturns400AndMetrics() async throws {
        let plugin = PayloadInspectionGatewayPlugin()
        let request = HTTPRequest(method: "POST", path: "/inspect", body: Data())
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

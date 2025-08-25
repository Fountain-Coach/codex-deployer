import XCTest
import Foundation
import FountainCodex
@testable import LLMGatewayPlugin

final class SentinelConsultHandlerTests: XCTestCase {
    private var handlers: Handlers!

    override func setUp() {
        handlers = Handlers()
    }

    override func tearDown() {
        handlers = nil
    }

    private func consult(summary: String) async throws -> String {
        let requestBody = SecurityCheckRequest(summary: summary, user: "user", resources: [])
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult")
        let resp = try await handlers.sentinelConsult(request, body: requestBody)
        let decisionResp = try JSONDecoder().decode(SecurityDecision.self, from: resp.body)
        return decisionResp.decision
    }

    func testAllow() async throws {
        let result = try await consult(summary: "all good")
        XCTAssertEqual(result, "allow")
    }

    func testDeny() async throws {
        let result = try await consult(summary: "danger ahead")
        XCTAssertEqual(result, "deny")
    }

    func testEscalate() async throws {
        let result = try await consult(summary: "escalate now")
        XCTAssertEqual(result, "escalate")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

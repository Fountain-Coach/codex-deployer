import XCTest
import Foundation
@testable import DestructiveGuardianGatewayPlugin
import FountainRuntime

final class DestructiveGuardianGatewayPluginTests: XCTestCase {
    private func makePlugin(logURL: URL, tokens: [String] = []) -> DestructiveGuardianGatewayPlugin {
        DestructiveGuardianGatewayPlugin(sensitivePaths: ["/secret"], privilegedTokens: tokens, auditURL: logURL)
    }

    func testDeniesWithoutApproval() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL, tokens: ["t1"])
        let eval = GuardianEvaluateRequest(method: "DELETE", path: "/secret", manualApproval: false, serviceToken: nil)
        let body = try JSONEncoder().encode(eval)
        let request = HTTPRequest(method: "POST", path: "/guardian/evaluate", body: body)
        guard let resp = try await plugin.router.route(request) else {
            return XCTFail("no response")
        }
        let decision = try JSONDecoder().decode(GuardianEvaluateResponse.self, from: resp.body)
        XCTAssertEqual(decision.decision, "deny")
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("deny"))
    }

    func testAllowsWithManualApproval() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL)
        let eval = GuardianEvaluateRequest(method: "PUT", path: "/secret", manualApproval: true, serviceToken: nil)
        let body = try JSONEncoder().encode(eval)
        let request = HTTPRequest(method: "POST", path: "/guardian/evaluate", body: body)
        guard let resp = try await plugin.router.route(request) else {
            return XCTFail("no response")
        }
        let decision = try JSONDecoder().decode(GuardianEvaluateResponse.self, from: resp.body)
        XCTAssertEqual(decision.decision, "allow")
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("allow"))
    }

    func testAllowsWithServiceToken() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL, tokens: ["abc"])
        let eval = GuardianEvaluateRequest(method: "PATCH", path: "/secret", manualApproval: false, serviceToken: "abc")
        let body = try JSONEncoder().encode(eval)
        let request = HTTPRequest(method: "POST", path: "/guardian/evaluate", body: body)
        guard let resp = try await plugin.router.route(request) else {
            return XCTFail("no response")
        }
        let decision = try JSONDecoder().decode(GuardianEvaluateResponse.self, from: resp.body)
        XCTAssertEqual(decision.decision, "allow")
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("allow"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

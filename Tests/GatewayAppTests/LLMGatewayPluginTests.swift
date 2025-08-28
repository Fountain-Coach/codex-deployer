import XCTest
import Foundation
@testable import LLMGatewayPlugin
import FountainRuntime

final class LLMGatewayPluginTests: XCTestCase {
    func testSentinelConsultDecisions() async throws {
        let plugin = LLMGatewayPlugin()
        let reqBody = SecurityCheckRequest(summary: "please delete", user: "u", resources: [])
        let data = try JSONEncoder().encode(reqBody)
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult", body: data)
        let resp = try await plugin.router.route(request)
        let decision = try JSONDecoder().decode(SecurityDecision.self, from: resp!.body)
        XCTAssertEqual(decision.decision, "deny")

        let allowBody = SecurityCheckRequest(summary: "safe action", user: "u", resources: [])
        let allowData = try JSONEncoder().encode(allowBody)
        let allowReq = HTTPRequest(method: "POST", path: "/sentinel/consult", body: allowData)
        let allowResp = try await plugin.router.route(allowReq)
        let allowDecision = try JSONDecoder().decode(SecurityDecision.self, from: allowResp!.body)
        XCTAssertEqual(allowDecision.decision, "allow")
    }

    func testChatCoTRoleRedaction() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let entry = ["id": "chat-1", "cot": "my secret plan"]
        let data = try JSONSerialization.data(withJSONObject: entry)
        let line = String(data: data, encoding: .utf8)! + "\n"
        try line.write(to: logURL, atomically: true, encoding: .utf8)
        let plugin = LLMGatewayPlugin(cotLogURL: logURL)
        let devReq = HTTPRequest(method: "GET", path: "/chat/chat-1/cot", headers: ["X-User-Role": "developer"])
        let devResp = try await plugin.router.route(devReq)
        let devObj = try JSONSerialization.jsonObject(with: devResp!.body) as? [String: Any]
        XCTAssertEqual(devObj?["cot"] as? String, "my [REDACTED] plan")

        let userReq = HTTPRequest(method: "GET", path: "/chat/chat-1/cot", headers: ["X-User-Role": "user"])
        let userResp = try await plugin.router.route(userReq)
        let userObj = try JSONSerialization.jsonObject(with: userResp!.body) as? [String: Any]
        XCTAssertNotNil(userObj?["cot_summary"] as? String)
        XCTAssertNil(userObj?["cot"])
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

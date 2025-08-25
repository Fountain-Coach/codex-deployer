import XCTest
import FountainCodex
@testable import LLMGatewayPlugin

final class CoTEndpointTests: XCTestCase {
    func testDeveloperGetsFullCoT() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let entry = ["id": "chat-1", "cot": "my secret plan"]
        let data = try JSONSerialization.data(withJSONObject: entry)
        let line = String(data: data, encoding: .utf8)! + "\n"
        try line.write(to: logURL, atomically: true, encoding: .utf8)
        let request = HTTPRequest(method: "GET", path: "/chat/chat-1/cot", headers: ["X-User-Role": "developer"])
        let handlers = Handlers(cotLogURL: logURL)
        let response = try await handlers.chatCoT(request, chatID: "chat-1")
        let obj = try JSONSerialization.jsonObject(with: Data(response.body)) as? [String: Any]
        XCTAssertEqual(obj?["cot"] as? String, "my [REDACTED] plan")
    }

    func testUserGetsSummary() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let entry = ["id": "chat-2", "cot": "top secret steps"]
        let data = try JSONSerialization.data(withJSONObject: entry)
        let line = String(data: data, encoding: .utf8)! + "\n"
        try line.write(to: logURL, atomically: true, encoding: .utf8)
        let request = HTTPRequest(method: "GET", path: "/chat/chat-2/cot", headers: ["X-User-Role": "user"])
        let handlers = Handlers(cotLogURL: logURL)
        let response = try await handlers.chatCoT(request, chatID: "chat-2")
        let obj = try JSONSerialization.jsonObject(with: Data(response.body)) as? [String: Any]
        XCTAssertNotNil(obj?["cot_summary"] as? String)
        XCTAssertNil(obj?["cot"])
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

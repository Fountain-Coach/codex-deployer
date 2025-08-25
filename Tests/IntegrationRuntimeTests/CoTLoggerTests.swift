import XCTest
@testable import gateway_server
@testable import FountainCodex

final class CoTLoggerTests: XCTestCase {
    /// Ensures reasoning steps are logged when include_cot is true.
    func testLogsCoTWhenRequested() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = CoTLogger(logURL: url)
        let reqBody = try JSONSerialization.data(withJSONObject: ["include_cot": true])
        let request = HTTPRequest(method: "POST", path: "/chat", body: reqBody)
        let respBody = try JSONSerialization.data(withJSONObject: ["id": "chat-1", "cot": "use secret key"])
        let response = HTTPResponse(status: 200, body: respBody)
        _ = try await plugin.respond(response, for: request)
        let logged = try String(contentsOf: url, encoding: .utf8)
        let lineData = Data(logged.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        let obj = try JSONSerialization.jsonObject(with: lineData) as? [String: Any]
        XCTAssertEqual(obj?["id"] as? String, "chat-1")
        let cot = obj?["cot"] as? String
        XCTAssertEqual(cot, "use [REDACTED] key")
    }

    /// Verifies no log is written when the flag is absent.
    func testSkipsLoggingWithoutFlag() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = CoTLogger(logURL: url)
        let request = HTTPRequest(method: "POST", path: "/chat")
        let respBody = try JSONSerialization.data(withJSONObject: ["cot": ["x"]])
        let response = HTTPResponse(status: 200, body: respBody)
        _ = try await plugin.respond(response, for: request)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    /// Ensures sentinel decision is logged when risky operations appear.
    func testLogsSentinelDecisionForRiskyCoT() async throws {
        let cotURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sentinelLog = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let sentinel = SecuritySentinelPlugin(logURL: sentinelLog)
        let plugin = CoTLogger(logURL: cotURL, sentinel: sentinel)

        let reqBody = try JSONSerialization.data(withJSONObject: ["include_cot": true])
        let request = HTTPRequest(method: "POST", path: "/chat", body: reqBody)
        let respBody = try JSONSerialization.data(withJSONObject: ["id": "chat-2", "cot": "delete file.txt"])
        let response = HTTPResponse(status: 200, body: respBody)
        _ = try await plugin.respond(response, for: request)

        let logged = try String(contentsOf: cotURL, encoding: .utf8)
        let lineData = Data(logged.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        let obj = try JSONSerialization.jsonObject(with: lineData) as? [String: Any]
        XCTAssertEqual(obj?["sentinel_decision"] as? String, "deny")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


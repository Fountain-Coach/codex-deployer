import XCTest
import Foundation
@testable import gateway_server
import FountainCodex

final class PayloadInspectionPluginTests: XCTestCase {
    func testSanitizesDeniedPattern() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = PayloadInspectionPlugin(denyList: ["secret"], transformations: ["secret": "[REDACTED]"], logURL: logURL)
        var request = HTTPRequest(method: "POST", path: "/a", body: Data("secret value".utf8))
        request = try await plugin.prepare(request)
        let body = String(data: request.body, encoding: .utf8)
        XCTAssertEqual(body, "[REDACTED] value")
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("sanitize"))
    }

    func testRejectsDeniedPattern() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = PayloadInspectionPlugin(denyList: ["token"], logURL: logURL)
        let request = HTTPRequest(method: "POST", path: "/b", body: Data("token=123".utf8))
        do {
            _ = try await plugin.prepare(request)
            XCTFail("expected reject")
        } catch is PayloadRejectedError {
            let log = try String(contentsOf: logURL, encoding: .utf8)
            XCTAssertTrue(log.contains("reject"))
        }
    }

    func testSanitizesResponseBody() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = PayloadInspectionPlugin(denyList: ["secret"], transformations: ["secret": "clean"], logURL: logURL)
        let response = HTTPResponse(body: Data("secret sauce".utf8))
        let request = HTTPRequest(method: "GET", path: "/c")
        let sanitized = try await plugin.respond(response, for: request)
        let text = String(data: sanitized.body, encoding: .utf8)
        XCTAssertEqual(text, "clean sauce")
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("sanitize"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import Foundation
@testable import gateway_server
import FountainCodex

final class SecuritySentinelPluginTests: XCTestCase {
    private func makePlugin(logURL: URL) -> SecuritySentinelPlugin {
        SecuritySentinelPlugin(logURL: logURL)
    }

    func testAllow() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL)
        let decision = try await plugin.consult(summary: "nothing risky", user: "u", resources: [])
        XCTAssertEqual(decision, .allow)
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("allow"))
    }

    func testDeny() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL)
        let request = HTTPRequest(method: "DELETE", path: "/danger")
        do {
            _ = try await plugin.prepare(request)
            XCTFail("expected deny")
        } catch is DeniedError {
            let log = try String(contentsOf: logURL, encoding: .utf8)
            XCTAssertTrue(log.contains("deny"))
        }
    }

    func testEscalate() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL)
        let request = HTTPRequest(method: "DELETE", path: "/need-escalate")
        do {
            _ = try await plugin.prepare(request)
            XCTFail("expected escalate")
        } catch is EscalateError {
            let log = try String(contentsOf: logURL, encoding: .utf8)
            XCTAssertTrue(log.contains("escalate"))
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

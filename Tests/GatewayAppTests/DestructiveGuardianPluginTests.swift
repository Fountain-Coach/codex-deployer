import XCTest
import Foundation
@testable import gateway_server
import FountainCodex

final class DestructiveGuardianPluginTests: XCTestCase {
    private func makePlugin(logURL: URL, tokens: [String] = []) -> DestructiveGuardianPlugin {
        DestructiveGuardianPlugin(sensitivePaths: ["/secret"], privilegedTokens: tokens, auditURL: logURL)
    }

    func testDeniesWithoutApproval() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL, tokens: ["t1"])
        let request = HTTPRequest(method: "DELETE", path: "/secret")
        do {
            _ = try await plugin.prepare(request)
            XCTFail("expected deny")
        } catch is GuardianDeniedError {
            let log = try String(contentsOf: logURL, encoding: .utf8)
            XCTAssertTrue(log.contains("deny"))
        }
    }

    func testAllowsWithManualApproval() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL)
        var request = HTTPRequest(method: "PUT", path: "/secret")
        request.headers["X-Manual-Approval"] = "ok"
        _ = try await plugin.prepare(request)
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("allow"))
    }

    func testAllowsWithServiceToken() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(logURL: logURL, tokens: ["abc"])
        var request = HTTPRequest(method: "PATCH", path: "/secret")
        request.headers["X-Service-Token"] = "abc"
        _ = try await plugin.prepare(request)
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("allow"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

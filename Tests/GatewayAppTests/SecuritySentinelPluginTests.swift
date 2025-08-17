import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server
import LLMGatewayClient
import FountainCodex

final class SecuritySentinelPluginTests: XCTestCase {
    private struct StubSession: HTTPSession {
        let decision: String
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            let body = "{\"decision\":\"\(decision)\"}".data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (body, response)
        }
    }

    private func makePlugin(decision: String, logURL: URL) -> SecuritySentinelPlugin {
        let session = StubSession(decision: decision)
        let client = APIClient(baseURL: URL(string: "http://example.com")!, session: session)
        return SecuritySentinelPlugin(client: client, logURL: logURL)
    }

    func testAllow() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(decision: "allow", logURL: logURL)
        let request = HTTPRequest(method: "DELETE", path: "/danger")
        _ = try await plugin.prepare(request)
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("allow"))
    }

    func testDeny() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let plugin = makePlugin(decision: "deny", logURL: logURL)
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
        let plugin = makePlugin(decision: "escalate", logURL: logURL)
        let request = HTTPRequest(method: "DELETE", path: "/danger")
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

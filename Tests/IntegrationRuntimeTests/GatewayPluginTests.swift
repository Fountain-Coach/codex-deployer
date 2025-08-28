import XCTest
@testable import gateway_server
@testable import FountainRuntime

final class GatewayPluginTests: XCTestCase {
    /// Simple plugin that relies on default implementations.
    struct DummyPlugin: GatewayPlugin {}

    /// Ensures the default `prepare` returns the original request untouched.
    func testDefaultPrepareReturnsSameRequest() async throws {
        let plugin = DummyPlugin()
        let request = HTTPRequest(method: "GET", path: "/orig")
        let result = try await plugin.prepare(request)
        XCTAssertEqual(result.method, request.method)
        XCTAssertEqual(result.path, request.path)
    }

    /// Ensures the default `respond` returns the response without modification.
    func testDefaultRespondReturnsSameResponse() async throws {
        let plugin = DummyPlugin()
        let response = HTTPResponse(status: 204, body: Data())
        let request = HTTPRequest(method: "GET", path: "/")
        let result = try await plugin.respond(response, for: request)
        XCTAssertEqual(result.status, response.status)
        XCTAssertEqual(result.body, response.body)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

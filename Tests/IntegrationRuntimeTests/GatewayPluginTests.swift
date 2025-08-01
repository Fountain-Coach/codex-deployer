import XCTest
@testable import gateway_server
@testable import FountainCodex

final class GatewayPluginDefaultTests: XCTestCase {
    func testDefaultImplementationsPassThrough() async throws {
        struct Dummy: GatewayPlugin {}
        let plugin = Dummy()
        let request = HTTPRequest(method: "GET", path: "/foo")
        let prepared = try await plugin.prepare(request)
        XCTAssertEqual(prepared.path, request.path)
        let response = HTTPResponse(status: 201)
        let output = try await plugin.respond(response, for: request)
        XCTAssertEqual(output.status, response.status)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

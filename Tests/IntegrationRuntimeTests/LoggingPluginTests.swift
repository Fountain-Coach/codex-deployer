import XCTest
@testable import GatewayApp

final class LoggingPluginTests: XCTestCase {
    func testLoggingPluginPassThrough() async throws {
        let plugin = LoggingPlugin()
        let req = HTTPRequest(method: "GET", path: "/")
        let prepared = try await plugin.prepare(req)
        XCTAssertEqual(prepared.path, req.path)
        let response = HTTPResponse(status: 200)
        let resp = try await plugin.respond(response, for: req)
        XCTAssertEqual(resp.status, response.status)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

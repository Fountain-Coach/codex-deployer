import XCTest
@testable import gateway_server
@testable import FountainRuntime

final class LoggingPluginTests: XCTestCase {
    /// Verifies requests and responses pass through the ``LoggingPlugin``.
    func testLoggingPluginPassThrough() async throws {
        let plugin = LoggingPlugin()
        let req = HTTPRequest(method: "GET", path: "/")
        let prepared = try await plugin.prepare(req)
        XCTAssertEqual(prepared.path, req.path)
        let response = HTTPResponse(status: 200)
        let resp = try await plugin.respond(response, for: req)
        XCTAssertEqual(resp.status, response.status)
    }

    /// Ensures headers and body are forwarded unchanged when preparing requests.
    func testPreparePreservesHeadersAndBody() async throws {
        let plugin = LoggingPlugin()
        let body = Data("hello".utf8)
        let req = HTTPRequest(method: "POST", path: "/data", headers: ["Foo": "Bar"], body: body)
        let prepared = try await plugin.prepare(req)
        XCTAssertEqual(prepared.headers, req.headers)
        XCTAssertEqual(prepared.body, req.body)
    }

    /// Ensures responses retain headers and body after logging.
    func testRespondPreservesHeadersAndBody() async throws {
        let plugin = LoggingPlugin()
        let response = HTTPResponse(status: 201, headers: ["X": "1"], body: Data("ok".utf8))
        let req = HTTPRequest(method: "GET", path: "/")
        let returned = try await plugin.respond(response, for: req)
        XCTAssertEqual(returned.headers, response.headers)
        XCTAssertEqual(returned.body, response.body)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

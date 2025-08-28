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

    /// Plugins should receive responses in the reverse order of registration.
    func testPipelineRespondsInReverseOrder() async throws {
        actor OrderTracker { var names: [String] = []; func record(_ n: String) { names.append(n) }; func snapshot() -> [String] { names } }
        struct RecordingPlugin: GatewayPlugin {
            let name: String
            let tracker: OrderTracker
            func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
                await tracker.record(name)
                return response
            }
        }
        let tracker = OrderTracker()
        let plugins: [GatewayPlugin] = [
            RecordingPlugin(name: "A", tracker: tracker),
            RecordingPlugin(name: "B", tracker: tracker),
            RecordingPlugin(name: "C", tracker: tracker)
        ]
        var resp = HTTPResponse(status: 200)
        let req = HTTPRequest(method: "GET", path: "/")
        for plugin in plugins.reversed() {
            resp = try await plugin.respond(resp, for: req)
        }
        let order = await tracker.snapshot()
        XCTAssertEqual(order, ["C", "B", "A"])
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

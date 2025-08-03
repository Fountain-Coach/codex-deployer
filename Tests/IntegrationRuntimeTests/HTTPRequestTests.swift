import XCTest
@testable import FountainCodex

final class HTTPRequestTests: XCTestCase {
    /// Verifies default initializer values for ``HTTPRequest``.
    func testRequestDefaults() {
        let req = HTTPRequest(method: "GET", path: "/")
        XCTAssertEqual(req.method, "GET")
        XCTAssertEqual(req.path, "/")
        XCTAssertTrue(req.headers.isEmpty)
        XCTAssertEqual(req.body.count, 0)
    }

    /// Confirms headers and body are mutable.
    func testRequestMutation() {
        var req = HTTPRequest(method: "POST", path: "/data")
        req.headers["X-Test"] = "ok"
        req.body = Data("hi".utf8)
        XCTAssertEqual(req.headers["X-Test"], "ok")
        XCTAssertEqual(String(data: req.body, encoding: .utf8), "hi")
    }

    /// Initializes the request with custom headers and body values.
    func testRequestInitializerStoresValues() {
        let headers = ["X-Token": "abc"]
        let body = Data("payload".utf8)
        let req = HTTPRequest(method: "POST", path: "/data", headers: headers, body: body)
        XCTAssertEqual(req.headers["X-Token"], "abc")
        XCTAssertEqual(String(data: req.body, encoding: .utf8), "payload")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

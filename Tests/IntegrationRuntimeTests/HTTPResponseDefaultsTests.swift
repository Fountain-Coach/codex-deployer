import XCTest
@testable import FountainCodex

final class HTTPResponseDefaultsTests: XCTestCase {
    /// Verifies default initializer values for ``HTTPResponse``.
    func testResponseDefaults() {
        let response = HTTPResponse()
        XCTAssertEqual(response.status, 200)
        XCTAssertTrue(response.headers.isEmpty)
        XCTAssertEqual(response.body.count, 0)
    }

    /// Confirms ``NoBody`` encodes and decodes without data loss.
    func testNoBodyCodable() throws {
        let data = try JSONEncoder().encode(NoBody())
        let decoded = try JSONDecoder().decode(NoBody.self, from: data)
        XCTAssertNotNil(decoded)
    }

    /// Initializes the response with custom status, headers, and body.
    func testResponseInitializerStoresValues() {
        let headers = ["Content-Type": "text/plain"]
        let body = Data("ok".utf8)
        let response = HTTPResponse(status: 201, headers: headers, body: body)
        XCTAssertEqual(response.status, 201)
        XCTAssertEqual(response.headers["Content-Type"], "text/plain")
        XCTAssertEqual(String(data: response.body, encoding: .utf8), "ok")
    }

    /// Ensures headers remain mutable after initialization.
    func testResponseHeadersMutation() {
        var response = HTTPResponse()
        response.headers["X-Test"] = "1"
        XCTAssertEqual(response.headers["X-Test"], "1")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

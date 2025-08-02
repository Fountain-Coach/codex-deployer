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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

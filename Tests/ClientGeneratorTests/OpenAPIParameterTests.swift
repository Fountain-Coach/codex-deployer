import XCTest
@testable import FountainCodex

final class OpenAPIParameterTests: XCTestCase {
    /// Ensures hyphens are converted to underscores for Swift identifiers.
    func testSwiftNameReplacesHyphenWithUnderscore() {
        let param = OpenAPISpec.Parameter(name: "x-id", location: "query")
        XCTAssertEqual(param.swiftName, "x_id")
    }

    /// Verifies schema-based type inference and defaulting to `String`.
    func testSwiftTypeUsesSchemaOrDefaultsToString() {
        var param = OpenAPISpec.Parameter(name: "count", location: "query")
        let schema = OpenAPISpec.Schema()
        schema.type = "integer"
        param.schema = schema
        XCTAssertEqual(param.swiftType, "Int")
        param.schema = nil
        XCTAssertEqual(param.swiftType, "String")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

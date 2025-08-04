import XCTest
@testable import FountainCodex

final class OpenAPISwiftTypeTests: XCTestCase {
    /// Verifies the `swiftType` helper produces the correct Swift type name.
    func testSchemaPropertySwiftType() {
        let prop = OpenAPISpec.Schema.Property()
        prop.type = "array"
        let item = OpenAPISpec.Schema()
        item.type = "string"
        prop.items = item
        XCTAssertEqual(prop.swiftType, "[String]")
    }

    /// Ensures schema references are converted to the last path component.
    func testSchemaRefSwiftType() {
        let schema = OpenAPISpec.Schema()
        schema.ref = "#/components/schemas/Todo"
        XCTAssertEqual(schema.swiftType, "Todo")
    }

    /// Maps object properties with `additionalProperties` to dictionaries.
    func testSchemaPropertyObjectSwiftType() {
        let prop = OpenAPISpec.Schema.Property()
        prop.type = "object"
        let value = OpenAPISpec.Schema()
        value.type = "integer"
        prop.additionalProperties = value
        XCTAssertEqual(prop.swiftType, "[String: Int]")
    }

    /// Defaults to `String` when no type information is present.
    func testSchemaPropertyUnknownTypeDefaultsToString() {
        let prop = OpenAPISpec.Schema.Property()
        XCTAssertEqual(prop.swiftType, "String")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

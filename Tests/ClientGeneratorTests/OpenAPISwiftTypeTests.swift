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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

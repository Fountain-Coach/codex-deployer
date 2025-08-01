import XCTest
@testable import FountainCodex

final class SpecValidatorTests: XCTestCase {
    func testDuplicateOperationIdThrows() throws {
        var op = OpenAPISpec.Operation(operationId: "op", parameters: nil, requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        var spec = OpenAPISpec(title: "API", servers: nil, components: nil, paths: [
            "/a": item,
            "/b": item
        ])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("duplicate operationId"))
        }
    }

    func testUnresolvedSchemaReferenceThrows() throws {
        var paramSchema = OpenAPISpec.Schema()
        paramSchema.ref = "#/components/schemas/Missing"
        let param = OpenAPISpec.Parameter(name: "id", location: "path", required: true, schema: paramSchema)
        var op = OpenAPISpec.Operation(operationId: "get", parameters: [param], requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let components = OpenAPISpec.Components(schemas: [:], securitySchemes: nil)
        var spec = OpenAPISpec(title: "API", servers: nil, components: components, paths: ["/item/{id}": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("unresolved reference"))
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

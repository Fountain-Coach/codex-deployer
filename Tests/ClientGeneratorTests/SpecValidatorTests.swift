import XCTest
@testable import FountainRuntime

final class SpecValidatorTests: XCTestCase {
    func testDuplicateOperationIdThrows() throws {
        let op = OpenAPISpec.Operation(operationId: "op", parameters: nil, requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let spec = OpenAPISpec(title: "API", servers: nil, components: nil, paths: [
            "/a": item,
            "/b": item
        ])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("duplicate operationId"))
        }
    }

    func testUnresolvedSchemaReferenceThrows() throws {
        let paramSchema = OpenAPISpec.Schema()
        paramSchema.ref = "#/components/schemas/Missing"
        let param = OpenAPISpec.Parameter(name: "id", location: "path", required: true, schema: paramSchema)
        let op = OpenAPISpec.Operation(operationId: "get", parameters: [param], requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let components = OpenAPISpec.Components(schemas: [:], securitySchemes: nil)
        let spec = OpenAPISpec(title: "API", servers: nil, components: components, paths: ["/item/{id}": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("unresolved reference"))
        }
    }

    /// Ensures that a missing placeholder parameter triggers validation failure.
    func testMissingPathParameterThrows() throws {
        let op = OpenAPISpec.Operation(operationId: "get", parameters: [], requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let spec = OpenAPISpec(title: "API", servers: nil, components: nil, paths: ["/items/{id}": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("missing parameter"))
        }
    }

    /// Ensures path parameters must be declared as required.
    func testPathParameterMustBeRequired() throws {
        let param = OpenAPISpec.Parameter(name: "id", location: "path", required: false, schema: nil)
        let op = OpenAPISpec.Operation(operationId: "get", parameters: [param], requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let spec = OpenAPISpec(title: "API", servers: nil, components: nil, paths: ["/items/{id}": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("must be required"))
        }
    }

    /// Ensures unknown security schemes referenced by operations trigger errors.
    func testUnknownSecuritySchemeThrows() throws {
        let requirement = OpenAPISpec.SecurityRequirement(schemes: ["auth": []])
        let op = OpenAPISpec.Operation(operationId: "get", parameters: nil, requestBody: nil, responses: nil, security: [requirement])
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let components = OpenAPISpec.Components(schemas: [:], securitySchemes: [:])
        let spec = OpenAPISpec(title: "API", servers: nil, components: components, paths: ["/": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("unknown security scheme"))
        }
    }

    /// Ensures an empty specification title triggers validation failure.
    func testEmptyTitleThrows() throws {
        let spec = OpenAPISpec(title: "   ", servers: nil, components: nil, paths: nil)
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("title cannot be empty"))
        }
    }

    /// Ensures parameters must declare a non-empty name.
    func testEmptyParameterNameThrows() throws {
        let param = OpenAPISpec.Parameter(name: "  ", location: "query", required: false, schema: nil)
        let op = OpenAPISpec.Operation(operationId: "get", parameters: [param], requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let spec = OpenAPISpec(title: "API", servers: nil, components: nil, paths: ["/": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("parameter name cannot be empty"))
        }
    }

    /// Ensures parameters must declare where they appear in the request.
    func testEmptyParameterLocationThrows() throws {
        let param = OpenAPISpec.Parameter(name: "id", location: "   ", required: false, schema: nil)
        let op = OpenAPISpec.Operation(operationId: "get", parameters: [param], requestBody: nil, responses: nil, security: nil)
        let item = OpenAPISpec.PathItem(get: op, post: nil, put: nil, delete: nil)
        let spec = OpenAPISpec(title: "API", servers: nil, components: nil, paths: ["/": item])
        XCTAssertThrowsError(try SpecValidator.validate(spec)) { error in
            XCTAssertTrue("\(error)".contains("parameter location cannot be empty"))
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

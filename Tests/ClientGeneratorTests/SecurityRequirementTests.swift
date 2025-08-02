import XCTest
@testable import FountainCodex

/// Tests encoding and decoding of ``OpenAPISpec.SecurityRequirement``.
final class SecurityRequirementTests: XCTestCase {
    /// Decoding a security requirement from JSON yields the expected mapping.
    func testDecodesSchemesFromJSON() throws {
        let json = """
        {"api_key":[],"oauth":["read","write"]}
        """.data(using: .utf8)!
        let requirement = try JSONDecoder().decode(OpenAPISpec.SecurityRequirement.self, from: json)
        XCTAssertEqual(requirement.schemes["api_key"], [])
        XCTAssertEqual(requirement.schemes["oauth"], ["read", "write"])
    }

    /// Encoding a requirement produces the correct JSON structure.
    func testEncodesSchemesToJSON() throws {
        let requirement = OpenAPISpec.SecurityRequirement(schemes: ["oauth": ["read"]])
        let data = try JSONEncoder().encode(requirement)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
        XCTAssertEqual(object?["oauth"], ["read"])
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

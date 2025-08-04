import XCTest
@testable import FountainCodex

final class StringExtensionTests: XCTestCase {
    /// Ensures the `camelCased` computed property transforms snake case names.
    func testCamelCased() {
        XCTAssertEqual("hello_world".camelCased, "helloWorld")
        XCTAssertEqual("AlreadyCamel".camelCased, "alreadycamel")
    }

    /// Empty strings remain unchanged.
    func testCamelCasedEmptyString() {
        XCTAssertEqual("".camelCased, "")
    }

    /// Multiple underscores create capitalized boundaries.
    func testCamelCasedMultipleUnderscores() {
        XCTAssertEqual("one_two_three".camelCased, "oneTwoThree")
    }

    /// Leading underscores are removed during conversion.
    func testCamelCasedLeadingUnderscore() {
        XCTAssertEqual("_hidden_name".camelCased, "hiddenName")
    }

    /// Numeric components remain intact when camelCasing.
    func testCamelCasedNumbers() {
        XCTAssertEqual("api_v2_endpoint".camelCased, "apiV2Endpoint")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

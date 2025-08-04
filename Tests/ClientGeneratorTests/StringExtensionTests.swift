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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
@testable import flexctl

final class FlexctlTests: XCTestCase {
    func testLoadUMP() throws {
        let words = try loadUMP(path: "midi/examples/planner.execute.ump")
        XCTAssertEqual(words.count, 4)
        XCTAssertEqual(words[0], 3490775296)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

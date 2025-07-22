import XCTest
@testable import Teatro

final class FountainParserTests: XCTestCase {
    func testParsesSceneHeadingAndCharacter() {
        let text = """
TITLE: Example

INT. HOUSE - DAY

JOHN
Hello.
"""
        let parser = FountainParser()
        let nodes = parser.parse(text)
        XCTAssertEqual(nodes.first?.type, .titlePageField(key: "TITLE"))
        XCTAssertTrue(nodes.contains { $0.type == .sceneHeading })
        XCTAssertTrue(nodes.contains { $0.type == .character })
        XCTAssertTrue(nodes.contains { $0.type == .dialogue })
    }

    func testParsesNote() {
        let parser = FountainParser()
        let nodes = parser.parse("[[note]]")
        XCTAssertEqual(nodes.first?.type, .note)
    }
}


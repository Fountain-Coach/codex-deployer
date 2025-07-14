import XCTest
@testable import Teatro

final class ViewCoreTests: XCTestCase {
    func testTextRendering() {
        let text = Text("Hello", style: .bold)
        XCTAssertEqual(text.render(), "**Hello**")
    }

    func testVStackRendering() {
        let stack = VStack(alignment: .leading, padding: 2) {
            Text("A")
            Text("B", style: .italic)
        }
        let expected = "  A\n  *B*"
        XCTAssertEqual(stack.render(), expected)
    }

    func testHStackRendering() {
        let stack = HStack(padding: 1) {
            Text("A")
            Text("B")
        }
        XCTAssertEqual(stack.render(), " A B")
    }
}

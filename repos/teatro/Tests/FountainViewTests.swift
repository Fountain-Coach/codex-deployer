import XCTest
@testable import Teatro

final class FountainViewTests: XCTestCase {
    func testParseAndRender() {
        let script = """
INT. LAB - NIGHT
The robot powers up.
ROBOT
  Hello.
CUT TO:
EXT. CITY - DAY
"""
        let view = FountainSceneView(fountainText: script)
        let lines = view.render().components(separatedBy: "\n")
        XCTAssertEqual(lines.first, "# INT. LAB - NIGHT")
        XCTAssertTrue(lines.contains("ROBOT"))
        XCTAssertTrue(lines.contains("\tHello."))
    }
}

import XCTest
import Teatro

@testable import ScreenplayGUI

final class ScreenplayGUITests: XCTestCase {
    func testParserProducesNodes() {
        let script = """
        INT. LAB - DAY
        AI
        Testing parser
        """
        let parser = FountainParser()
        let nodes = parser.parse(script)
        XCTAssertFalse(nodes.isEmpty)
    }

    func testDefaultScriptParses() {
        let parser = FountainParser()
        let nodes = parser.parse(ScriptEditorStage.defaultScript)
        XCTAssertFalse(nodes.isEmpty)
    }
}

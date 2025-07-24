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

    func testDirectiveBlockViewRendersInjectedResponse() {
#if canImport(SwiftUI)
        let response = "[tool output]"
        let view = DirectiveBlockView(.injected(.toolResponse(response)))
        let rendered = String(describing: view.body)
        XCTAssertTrue(rendered.contains(response))
#else
        XCTAssertTrue(true)
#endif
    }

    func testScreenplayMainStageUpdatesWhenBlocksInserted() async {
#if canImport(SwiftUI)
        let stage = ScreenplayMainStage()
        stage.viewModel.parseAndTrigger(
        """
        INT. LAB - DAY
        > tool_call: echo
        """
        )
        try? await Task.sleep(nanoseconds: 200_000_000)
        let injectedExists = stage.viewModel.blocks.contains { block in
            if case .injected = block { return true } else { return false }
        }
        XCTAssertTrue(injectedExists)
#else
        XCTAssertTrue(true)
#endif
    }
}

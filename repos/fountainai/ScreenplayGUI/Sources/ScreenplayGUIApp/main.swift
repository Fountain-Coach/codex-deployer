import Foundation
import Teatro
import ScreenplayGUI

let sampleScript = ScriptEditorStage.defaultScript

let parser = FountainParser()
let nodes = parser.parse(sampleScript)

for node in nodes {
    print("\(node.lineNumber): \(node.rawText)")
}

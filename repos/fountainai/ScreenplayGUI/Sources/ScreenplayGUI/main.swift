import Foundation
import Teatro

let sampleScript = """
Title: Sample

INT. LAB - DAY

DEVELOPER
Let's integrate Teatro!
"""

let parser = FountainParser()
let nodes = parser.parse(sampleScript)

for node in nodes {
    print("\(node.lineNumber): \(node.rawText)")
}

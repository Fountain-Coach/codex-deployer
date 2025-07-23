import Foundation
import SwiftUI

public final class ScriptExecutionEngine: ObservableObject {
    @Published public var script: String
    @Published public var blocks: [FountainDirective] = []

    public init(script: String = ScriptEditorStage.defaultScript) {
        self.script = script
    }

    public func run() {
        blocks = execute(script: script)
    }


    public func execute(script: String) -> [FountainDirective] {
        var blocks: [FountainDirective] = []
        let lines = script.split(separator: "\n", omittingEmptySubsequences: false)
        for lineSub in lines {
            let line = String(lineSub)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            blocks.append(.editor(line))
            let lower = trimmed.lowercased()
            if lower.hasPrefix("> tool_call:") {
                let content = String(trimmed.dropFirst(11)).trimmingCharacters(in: .whitespaces)
                let output = ">>> executed \(content)"
                blocks.append(.response(output))
            } else if lower.hasPrefix("> sse:") {
                let content = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                let output = ">>> stream \(content)"
                blocks.append(.response(output))
            }
        }
        return blocks
    }
}


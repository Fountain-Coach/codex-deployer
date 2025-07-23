import Foundation

public final class ScriptExecutionEngine {
    public init() {}

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


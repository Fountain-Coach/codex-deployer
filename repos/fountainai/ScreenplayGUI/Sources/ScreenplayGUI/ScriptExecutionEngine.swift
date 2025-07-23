import Foundation
import SwiftUI
import Teatro

public final class ScriptExecutionEngine: ObservableObject {
    @Published public var script: String
    @Published public var blocks: [FountainLineBlock] = []
    private let parser = FountainParser()

    public init(script: String = ScriptEditorStage.defaultScript) {
        self.script = script
    }

    public func run() {
        parseAndTrigger(script)
    }

    public func parseAndTrigger(_ script: String) {
        let parsed = parser.parse(script)
        blocks = []
        for (i, node) in parsed.enumerated() {
            let block = FountainLineBlock.line(text: node.rawText, trigger: trigger(for: node))
            blocks.append(block)
            if let trigger = block.trigger {
                handle(trigger, after: i)
            }
        }
    }

    private func trigger(for node: FountainNode) -> OrchestrationTrigger? {
        switch node.type {
        case .toolCall:
            let value = node.rawText.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            return .toolCall(endpoint: value)
        case .sse:
            let value = node.rawText.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            return .sse(filename: value)
        case .reflect:
            return .reflect
        case .promote:
            let value = node.rawText.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            return .promote(role: value)
        case .summary:
            return .summary
        default:
            return nil
        }
    }

    private func handle(_ trigger: OrchestrationTrigger, after index: Int) {
        switch trigger {
        case .toolCall(let endpoint):
            callToolAPI(endpoint) { response in
                self.insert(.injected(.toolResponse(response)), after: index)
            }
        case .reflect:
            reflect { reply in
                self.insert(.injected(.reflectionReply(reply)), after: index)
            }
        case .sse(let file):
            streamMarkdown(file) { chunk in
                self.insert(.injected(.sseChunk(chunk)), after: index)
            }
        case .promote(let role):
            promoteRole(role) { conf in
                self.insert(.injected(.promotionConfirmation(conf)), after: index)
            }
        case .summary:
            summarizeCorpus { summary in
                self.insert(.injected(.summaryBlock(summary)), after: index)
            }
        }
    }

    private func insert(_ block: FountainLineBlock, after index: Int) {
        DispatchQueue.main.async {
            if index + 1 <= self.blocks.count {
                self.blocks.insert(block, at: index + 1)
            } else {
                self.blocks.append(block)
            }
        }
    }

    // MARK: - Mock orchestration helpers
    private func callToolAPI(_ endpoint: String, completion: @escaping (String) -> Void) {
        completion("[tool output: \(endpoint)]")
    }

    private func reflect(completion: @escaping (String) -> Void) {
        completion("[reflection]")
    }

    private func streamMarkdown(_ filename: String, chunk: @escaping (String) -> Void) {
        chunk("[stream from \(filename)]")
    }

    private func promoteRole(_ role: String, completion: @escaping (String) -> Void) {
        completion("[promoted \(role)]")
    }

    private func summarizeCorpus(completion: @escaping (String) -> Void) {
        completion("[summary]")
    }
}

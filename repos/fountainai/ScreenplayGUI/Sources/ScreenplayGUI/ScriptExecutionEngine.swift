import Foundation
import Teatro

#if canImport(SwiftUI)
import SwiftUI

@MainActor
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
            let block = FountainLineBlock.line(text: node.rawText, type: node.type, trigger: trigger(for: node))
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
            Task {
                let response = await callToolAPI(endpoint)
                await MainActor.run {
                    insert(.injected(.toolResponse(response)), after: index)
                }
            }
        case .reflect:
            Task {
                let reply = await reflect()
                await MainActor.run {
                    insert(.injected(.reflectionReply(reply)), after: index)
                }
            }
        case .sse(let file):
            Task {
                let chunk = await streamMarkdown(file)
                await MainActor.run {
                    insert(.injected(.sseChunk(chunk)), after: index)
                }
            }
        case .promote(let role):
            Task {
                let conf = await promoteRole(role)
                await MainActor.run {
                    insert(.injected(.promotionConfirmation(conf)), after: index)
                }
            }
        case .summary:
            Task {
                let summary = await summarizeCorpus()
                await MainActor.run {
                    insert(.injected(.summaryBlock(summary)), after: index)
                }
            }
        }
    }

    private func insert(_ block: FountainLineBlock, after index: Int) {
        if index + 1 <= blocks.count {
            blocks.insert(block, at: index + 1)
        } else {
            blocks.append(block)
        }
    }

    // MARK: - Mock orchestration helpers
    private func callToolAPI(_ endpoint: String) async -> String {
        "[tool output: \(endpoint)]"
    }

    private func reflect() async -> String {
        "[reflection]"
    }

    private func streamMarkdown(_ filename: String) async -> String {
        "[stream from \(filename)]"
    }

    private func promoteRole(_ role: String) async -> String {
        "[promoted \(role)]"
    }

    private func summarizeCorpus() async -> String {
        "[summary]"
    }
}
#endif

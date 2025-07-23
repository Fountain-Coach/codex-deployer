import Foundation

extension FountainParser {
    // MARK: - FountainAI Rule Helpers
    func isCorpusHeader(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("#corpus:")
    }

    func isBaseline(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("> baseline:")
    }

    func isSSE(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("> sse:")
    }

    func isToolCall(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("> tool_call:")
    }

    func isReflect(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).uppercased().hasPrefix("REFLECT:")
    }

    func isPromote(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).uppercased().hasPrefix("PROMOTE:")
    }

    func isSummary(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).uppercased().hasPrefix("SUMMARY:")
    }
}

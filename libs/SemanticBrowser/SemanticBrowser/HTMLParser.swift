import Foundation

public struct HTMLParser {
    public init() {}

    public func parseBlocks(from html: String) -> [SemanticMemoryService.FullAnalysis.Block] {
        var blocks: [SemanticMemoryService.FullAnalysis.Block] = []

        // Headings: capture level and inner HTML, use inner text
        let headingPattern = "<h([1-6])[^>]*>(.*?)</h\\1>"
        for (i, match) in matchesTwoGroups(html, pattern: headingPattern).enumerated() {
            let text = match.1.removingHTMLTags()
            blocks.append(.init(id: "h\(i)", kind: "heading", text: text, table: nil))
        }

        // Paragraphs: capture inner HTML
        let pPattern = "<p[^>]*>(.*?)</p>"
        for (i, inner) in matchesOneGroup(html, pattern: pPattern).enumerated() {
            let text = inner.removingHTMLTags()
            blocks.append(.init(id: "p\(i)", kind: "paragraph", text: text, table: nil))
        }

        // Code/pre blocks: first group is tag name, second is inner content
        let prePattern = "<(pre|code)[^>]*>([\\s\\S]*?)</\\1>"
        for (i, match) in matchesTwoGroups(html, pattern: prePattern).enumerated() {
            let text = match.1.removingHTMLTags()
            blocks.append(.init(id: "c\(i)", kind: "code", text: text, table: nil))
        }

        // Tables (very simple extraction)
        let tPattern = "<table[\\s\\S]*?</table>"
        for (ti, tableHTML) in allMatches(html, pattern: tPattern).enumerated() {
            let caption = firstMatch(tableHTML, pattern: "<caption[^>]*>(.*?)</caption>")?.removingHTMLTags()
            var columns: [String]? = nil
            if let thead = firstMatch(tableHTML, pattern: "<thead[\\s\\S]*?</thead>") {
                let ths = allMatches(thead, pattern: "<th[^>]*>(.*?)</th>").map { $0.removingHTMLTags() }
                columns = ths.isEmpty ? nil : ths
            } else if let firstRow = firstMatch(tableHTML, pattern: "<tr[\\s\\S]*?</tr>") {
                let ths = allMatches(firstRow, pattern: "<th[^>]*>(.*?)</th>").map { $0.removingHTMLTags() }
                columns = ths.isEmpty ? nil : ths
            }
            let rowHTMLs = allMatches(tableHTML, pattern: "<tr[\\s\\S]*?</tr>")
            var rows: [[String]] = []
            for r in rowHTMLs {
                let cells = allMatches(r, pattern: "<t[dh][^>]*>(.*?)</t[dh]>").map { $0.removingHTMLTags() }
                if !cells.isEmpty { rows.append(cells) }
            }
            let table = SemanticMemoryService.FullAnalysis.Table(caption: caption, columns: columns, rows: rows)
            blocks.append(.init(id: "t\(ti)", kind: "table", text: "", table: table))
        }
        return blocks
    }

    // Naive entity extraction as a helper (optional)
    public func extractEntities(from blocks: [SemanticMemoryService.FullAnalysis.Block]) -> [SemanticMemoryService.FullAnalysis.Semantics.Entity] {
        var seen = Set<String>()
        var entities: [SemanticMemoryService.FullAnalysis.Semantics.Entity] = []
        for b in blocks where !b.text.isEmpty {
            let words = b.text.split(whereSeparator: { !$0.isLetter })
            for w in words {
                let s = String(w)
                if s.count >= 3,
                   s.prefix(1) == s.prefix(1).uppercased(),
                   s.dropFirst().rangeOfCharacter(from: .lowercaseLetters) != nil,
                   !seen.contains(s) {
                    seen.insert(s)
                    entities.append(.init(id: UUID().uuidString, name: s, type: "OTHER"))
                }
            }
        }
        return entities
    }

    // MARK: - Regex helpers
    private func matchesTwoGroups(_ s: String, pattern: String) -> [(String, String)] {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        return re.matches(in: s, options: [], range: range).compactMap { m in
            guard m.numberOfRanges >= 3,
                  let r1 = Range(m.range(at: 1), in: s),
                  let r2 = Range(m.range(at: 2), in: s) else { return nil }
            return (String(s[r1]), String(s[r2]))
        }
    }

    private func matchesOneGroup(_ s: String, pattern: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        return re.matches(in: s, options: [], range: range).compactMap { m in
            guard m.numberOfRanges >= 2, let r1 = Range(m.range(at: 1), in: s) else { return nil }
            return String(s[r1])
        }
    }

    private func allMatches(_ s: String, pattern: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        return re.matches(in: s, options: [], range: range).compactMap { m in
            guard let r = Range(m.range(at: 0), in: s) else { return nil }
            return String(s[r])
        }
    }

    private func firstMatch(_ s: String, pattern: String) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        guard let m = re.firstMatch(in: s, options: [], range: range), m.numberOfRanges >= 2, let r = Range(m.range(at: 1), in: s) else { return nil }
        return String(s[r])
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

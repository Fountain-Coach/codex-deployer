import Foundation

public struct HTMLParser {
    public init() {}

    public func parseBlocks(from html: String) -> [SemanticMemoryService.FullAnalysis.Block] {
        var blocks: [SemanticMemoryService.FullAnalysis.Block] = []
        // headings
        let headingPattern = "<h([1-6])[^>]*>(.*?)</h\\1>"
        blocks.append(contentsOf: matches(html, pattern: headingPattern).enumerated().map { i, m in
            let text = m.1.removingHTMLTags()
            return SemanticMemoryService.FullAnalysis.Block(id: "h\(i)", kind: "heading", text: text, table: nil)
        })
        // paragraphs
        let pPattern = "<p[^>]*>(.*?)</p>"
        blocks.append(contentsOf: matches(html, pattern: pPattern).enumerated().map { i, m in
            let text = m.1.removingHTMLTags()
            return SemanticMemoryService.FullAnalysis.Block(id: "p\(i)", kind: "paragraph", text: text, table: nil)
        })
        // tables
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
            blocks.append(SemanticMemoryService.FullAnalysis.Block(id: "t\(ti)", kind: "table", text: "", table: table))
        }
        return blocks
    }

    private func matches(_ s: String, pattern: String) -> [(String, String)] {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        return re.matches(in: s, options: [], range: range).compactMap { m in
            guard m.numberOfRanges >= 2, let r1 = Range(m.range(at: 1), in: s) else { return nil }
            let sub = String(s[r1])
            return (sub, sub)
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

extension String {
    func removingHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

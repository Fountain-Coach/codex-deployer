import Foundation

struct Index: Codable {
    struct Document: Codable {
        struct Page: Codable {
            struct Fragment: Codable {
                let text: String
                let x: Double
                let y: Double
            }
            let lines: [Fragment]
        }
        let pages: [Page]
    }
    let documents: [Document]
}

struct Matrix: Codable {
    var messages: [String]
    var enums: [String]
    var bitfields: [String]
    var ranges: [String]
}

func loadIndex() throws -> Index {
    let url = URL(fileURLWithPath: "models/index.verify.json")
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(Index.self, from: data)
}

func parseRows(from index: Index) -> [String] {
    var rows: [String] = []
    for document in index.documents {
        for page in document.pages {
            let grouped = Dictionary(grouping: page.lines) { Int(round($0.y)) }
            for y in grouped.keys.sorted() {
                let fragments = grouped[y]!.sorted { $0.x < $1.x }
                let text = fragments.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                if !text.isEmpty {
                    rows.append(text)
                }
            }
        }
    }
    return rows
}

func categorize(rows: [String]) -> Matrix {
    var matrix = Matrix(messages: [], enums: [], bitfields: [], ranges: [])
    for row in rows {
        let lower = row.lowercased()
        if lower.contains("bitfield") {
            matrix.bitfields.append(row)
        } else if lower.contains("enum") {
            matrix.enums.append(row)
        } else if lower.contains("range") {
            matrix.ranges.append(row)
        } else if lower.contains("message") {
            matrix.messages.append(row)
        }
    }
    return matrix
}

func write(matrix: Matrix) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(matrix)
    let url = URL(fileURLWithPath: "models/matrix.json")
    try data.write(to: url)
}

@main
struct Runner {
    static func main() throws {
        let index = try loadIndex()
        let rows = parseRows(from: index)
        let matrix = categorize(rows: rows)
        try write(matrix: matrix)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

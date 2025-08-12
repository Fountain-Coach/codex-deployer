import Foundation

struct MatrixEntry: Codable {
    var text: String
    var page: Int
    var x: Int
    var y: Int
}

struct BitField: Codable {
    var name: String
    var bits: [Int]
}

struct RangeSpec: Codable {
    var field: String
    var min: Int
    var max: Int
}

struct EnumCase: Codable {
    var name: String
    var value: Int
}

struct EnumSpec: Codable {
    var field: String
    var cases: [EnumCase]
}

struct TableCell: Codable {
    var row: Int
    var column: Int
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var text: String
}

struct TableModel: Codable {
    var rows: Int
    var columns: Int
    var cells: [TableCell]
}

struct TableDetector {
        static func detect(from index: IndexRoot) -> (messages: [MatrixEntry], terms: [MatrixEntry]) {
        var messages: [MatrixEntry] = []
        var terms: [MatrixEntry] = []
        for doc in index.documents {
            for page in doc.pages {
                // Prefer tokenized words if available; fall back to raw lines.
                let tokens = (page.words ?? page.lines).map { $0.text }
                for (i, token) in tokens.enumerated() {
                    let entry = MatrixEntry(text: token, page: page.number, x: 0, y: i)
                    let lower = token.lowercased()
                    if lower.contains("message") {
                        messages.append(entry)
                    }
                    if lower.contains("term") {
                        terms.append(entry)
                    }
                }
            }
        }
        return (messages, terms)
    }


    static func detectTables(from index: IndexRoot, threshold: Double = 5.0) -> [TableModel] {
        var tables: [TableModel] = []
        for doc in index.documents {
            for page in doc.pages {
                // Use token centers where available for better column detection
                let tokens = page.words ?? page.lines
                guard !tokens.isEmpty else { continue }
                // Use token vertical centers for rows and horizontal centers for columns
                let rowCenters = cluster(tokens.map { $0.y }, threshold: threshold)
                let columnCenters = cluster(tokens.map { $0.x + $0.width / 2.0 }, threshold: threshold)
                var cells: [TableCell] = []
                for (ri, ry) in rowCenters.enumerated() {
                    for (ci, cx) in columnCenters.enumerated() {
                        // find nearest token whose center is close to (cx, ry)
                        if let match = tokens.min(by: { abs(($0.x + $0.width/2.0) - cx) + abs($0.y - ry) < abs(($1.x + $1.width/2.0) - cx) + abs($1.y - ry) }) {
                            if abs((match.x + match.width/2.0) - cx) <= threshold * 2 && abs(match.y - ry) <= threshold * 2 {
                                cells.append(TableCell(row: ri, column: ci, x: match.x, y: match.y, width: match.width, height: match.height, text: match.text))
                                continue
                            }
                        }
                        cells.append(TableCell(row: ri, column: ci, x: cx, y: ry, width: 0, height: 0, text: ""))
                    }
                }
                tables.append(TableModel(rows: rowCenters.count, columns: columnCenters.count, cells: cells))
            }
        }
        return tables
    }

    private static func cluster(_ values: [Double], threshold: Double) -> [Double] {
        let sorted = values.sorted()
        var centers: [Double] = []
        var counts: [Int] = []
        for v in sorted {
            if let last = centers.last, abs(v - last) <= threshold {
                let count = counts.removeLast()
                let newCenter = (last * Double(count) + v) / Double(count + 1)
                centers[centers.count - 1] = newCenter
                counts.append(count + 1)
            } else {
                centers.append(v)
                counts.append(1)
            }
        }
        return centers
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

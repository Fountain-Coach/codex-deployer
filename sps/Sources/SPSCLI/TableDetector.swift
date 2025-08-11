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
                let lines = page.text.split(whereSeparator: \.isNewline)
                for (i, lineSub) in lines.enumerated() {
                    let line = String(lineSub)
                    let entry = MatrixEntry(text: line, page: page.number, x: 0, y: i)
                    let lower = line.lowercased()
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
                let lines = page.lines
                guard !lines.isEmpty else { continue }
                let rowCenters = cluster(lines.map { $0.y }, threshold: threshold)
                let columnCenters = cluster(lines.map { $0.x }, threshold: threshold)
                var cells: [TableCell] = []
                for (ri, ry) in rowCenters.enumerated() {
                    for (ci, cx) in columnCenters.enumerated() {
                        if let match = lines.first(where: { abs($0.y - ry) <= threshold && abs($0.x - cx) <= threshold }) {
                            cells.append(TableCell(row: ri, column: ci, x: match.x, y: match.y, width: match.width, height: match.height, text: match.text))
                        } else {
                            cells.append(TableCell(row: ri, column: ci, x: cx, y: ry, width: 0, height: 0, text: ""))
                        }
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

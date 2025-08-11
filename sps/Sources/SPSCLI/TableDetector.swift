import Foundation

struct MatrixEntry: Codable {
    var text: String
    var page: Int
    var x: Int
    var y: Int
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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

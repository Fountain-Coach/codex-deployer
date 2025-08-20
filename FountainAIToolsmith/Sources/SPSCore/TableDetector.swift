import Foundation

// MARK: - Table Detection and Analysis

public struct TableCell: Codable {
    public var row: Int
    public var column: Int
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    public var text: String
    
    public init(row: Int, column: Int, x: Double, y: Double, width: Double, height: Double, text: String) {
        self.row = row
        self.column = column
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.text = text
    }
}

public struct TableModel: Codable {
    public var rows: Int
    public var columns: Int
    public var cells: [TableCell]
    
    public init(rows: Int, columns: Int, cells: [TableCell] = []) {
        self.rows = rows
        self.columns = columns
        self.cells = cells
    }
}

public struct TableDetector {
    public static func detect(from index: IndexRoot) -> (messages: [MatrixEntry], terms: [MatrixEntry]) {
        var messages: [MatrixEntry] = []
        var terms: [MatrixEntry] = []
        
        // Simple keyword-based detection for messages and terms
        let messageKeywords = ["message", "msg", "command", "event", "status"]
        let termKeywords = ["note", "velocity", "pitch", "channel", "controller", "program"]
        
        for doc in index.documents {
            for page in doc.pages {
                // Analyze lines for potential message/term entries
                for line in page.lines {
                    let lowerText = line.text.lowercased()
                    let trimmedText = line.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Skip empty or very short lines
                    guard !trimmedText.isEmpty && trimmedText.count >= 3 else { continue }
                    
                    // Check for message keywords
                    for keyword in messageKeywords {
                        if lowerText.contains(keyword) {
                            messages.append(MatrixEntry(
                                text: trimmedText,
                                page: page.number,
                                x: Int(line.x),
                                y: Int(line.y)
                            ))
                            break
                        }
                    }
                    
                    // Check for term keywords
                    for keyword in termKeywords {
                        if lowerText.contains(keyword) {
                            terms.append(MatrixEntry(
                                text: trimmedText,
                                page: page.number,
                                x: Int(line.x),
                                y: Int(line.y)
                            ))
                            break
                        }
                    }
                    
                    // Additional heuristics for table-like structures
                    if detectTableStructure(line: line) {
                        // Could be either message or term depending on content
                        if lowerText.contains("note") || lowerText.contains("velocity") {
                            terms.append(MatrixEntry(
                                text: trimmedText,
                                page: page.number,
                                x: Int(line.x),
                                y: Int(line.y)
                            ))
                        } else {
                            messages.append(MatrixEntry(
                                text: trimmedText,
                                page: page.number,
                                x: Int(line.x),
                                y: Int(line.y)
                            ))
                        }
                    }
                }
                
                // Also check full page text for pattern matching
                analyzePageText(page: page, messages: &messages, terms: &terms)
            }
        }
        
        // Remove duplicates and sort
        messages = Array(Set(messages.map { $0.text })).enumerated().map { index, text in
            MatrixEntry(text: text, page: 1, x: 0, y: index * 20)
        }
        
        terms = Array(Set(terms.map { $0.text })).enumerated().map { index, text in
            MatrixEntry(text: text, page: 1, x: 100, y: index * 20)
        }
        
        return (messages: messages, terms: terms)
    }
    
    public static func extractTables(from index: IndexRoot) -> [TableModel] {
        var tables: [TableModel] = []
        
        for doc in index.documents {
            for page in doc.pages {
                let pageTables = detectTablesInPage(page)
                tables.append(contentsOf: pageTables)
            }
        }
        
        return tables
    }
    
    // MARK: - Private Helpers
    
    private static func detectTableStructure(line: TextLine) -> Bool {
        let text = line.text
        
        // Look for table-like patterns
        let tabCount = text.components(separatedBy: "\t").count - 1
        let spaceGroups = text.components(separatedBy: "  ").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
        
        // Heuristics for table detection
        return tabCount >= 2 || spaceGroups >= 3 || 
               text.contains("|") || 
               text.contains("│") ||
               (text.contains(":") && text.contains(" "))
    }
    
    private static func analyzePageText(page: IndexPage, messages: inout [MatrixEntry], terms: inout [MatrixEntry]) {
        let fullText = page.text.lowercased()
        
        // Look for specific MIDI-related patterns
        let midiMessagePatterns = [
            "note on", "note off", "program change", "control change",
            "pitch bend", "aftertouch", "system exclusive"
        ]
        
        let midiTermPatterns = [
            "velocity", "channel", "pitch", "frequency", "amplitude",
            "controller", "program", "bank select"
        ]
        
        for pattern in midiMessagePatterns {
            if fullText.contains(pattern) {
                messages.append(MatrixEntry(
                    text: pattern.capitalized,
                    page: page.number,
                    x: 0,
                    y: messages.count * 20
                ))
            }
        }
        
        for pattern in midiTermPatterns {
            if fullText.contains(pattern) {
                terms.append(MatrixEntry(
                    text: pattern.capitalized,
                    page: page.number,
                    x: 100,
                    y: terms.count * 20
                ))
            }
        }
    }
    
    private static func detectTablesInPage(_ page: IndexPage) -> [TableModel] {
        var tables: [TableModel] = []
        
        // Group lines that might form tables based on vertical alignment
        let sortedLines = page.lines.sorted { $0.y < $1.y }
        var currentTable: [TextLine] = []
        var lastY: Double = -1
        
        for line in sortedLines {
            if detectTableStructure(line: line) {
                if lastY >= 0 && abs(line.y - lastY) > 30 {
                    // Start new table
                    if currentTable.count >= 2 {
                        tables.append(createTableFromLines(currentTable))
                    }
                    currentTable = [line]
                } else {
                    currentTable.append(line)
                }
                lastY = line.y
            } else {
                // End current table
                if currentTable.count >= 2 {
                    tables.append(createTableFromLines(currentTable))
                }
                currentTable = []
                lastY = -1
            }
        }
        
        // Handle final table
        if currentTable.count >= 2 {
            tables.append(createTableFromLines(currentTable))
        }
        
        return tables
    }
    
    private static func createTableFromLines(_ lines: [TextLine]) -> TableModel {
        var cells: [TableCell] = []
        
        for (rowIndex, line) in lines.enumerated() {
            // Simple column detection based on tab or multiple spaces
            let columns: [String]
            if line.text.contains("\t") {
                columns = line.text.components(separatedBy: "\t")
            } else {
                columns = line.text.components(separatedBy: "  ").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            }
            
            for (colIndex, columnText) in columns.enumerated() {
                let trimmed = columnText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    cells.append(TableCell(
                        row: rowIndex,
                        column: colIndex,
                        x: line.x + Double(colIndex * 100), // Approximate column position
                        y: line.y,
                        width: Double(trimmed.count * 8), // Approximate width
                        height: line.height,
                        text: trimmed
                    ))
                }
            }
        }
        
        let maxRow = cells.map { $0.row }.max() ?? 0
        let maxCol = cells.map { $0.column }.max() ?? 0
        
        return TableModel(
            rows: maxRow + 1,
            columns: maxCol + 1,
            cells: cells
        )
    }
}

// Make MatrixEntry hashable for Set operations
extension MatrixEntry: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(page)
        hasher.combine(x)
        hasher.combine(y)
    }
    
    public static func == (lhs: MatrixEntry, rhs: MatrixEntry) -> Bool {
        return lhs.text == rhs.text && lhs.page == rhs.page && lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
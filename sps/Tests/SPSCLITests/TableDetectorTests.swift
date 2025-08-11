import XCTest
@testable import SPSCLI

final class TableDetectorTests: XCTestCase {
    func testDetectTablesFillsGaps() throws {
        let lines = [
            TextLine(text: "A", x: 10, y: 10, width: 10, height: 10),
            TextLine(text: "C", x: 50, y: 10, width: 10, height: 10),
            TextLine(text: "1", x: 10, y: 30, width: 10, height: 10),
            TextLine(text: "2", x: 30, y: 30, width: 10, height: 10),
            TextLine(text: "3", x: 50, y: 30, width: 10, height: 10)
        ]
        let page = IndexPage(number: 1, text: "", lines: lines)
        let doc = IndexDoc(id: "1", fileName: "test.pdf", size: 0, sha256: nil, pages: [page])
        let index = IndexRoot(documents: [doc])
        let tables = TableDetector.detectTables(from: index, threshold: 1.0)
        XCTAssertEqual(tables.count, 1)
        let table = tables[0]
        XCTAssertEqual(table.rows, 2)
        XCTAssertEqual(table.columns, 3)
        let missing = table.cells.first { $0.row == 0 && $0.column == 1 }
        XCTAssertEqual(missing?.text, "")
        let present = table.cells.first { $0.row == 0 && $0.column == 0 }
        XCTAssertEqual(present?.text, "A")
    }

    func testDetectTablesEmptyInputReturnsNoTables() throws {
        let index = IndexRoot(documents: [])
        XCTAssertTrue(TableDetector.detectTables(from: index).isEmpty)
    }

    func testDetectTablesSingleCell() throws {
        let lines = [TextLine(text: "A", x: 1, y: 1, width: 1, height: 1)]
        let page = IndexPage(number: 1, text: "", lines: lines)
        let doc = IndexDoc(id: "1", fileName: "one.pdf", size: 0, sha256: nil, pages: [page])
        let index = IndexRoot(documents: [doc])
        let tables = TableDetector.detectTables(from: index, threshold: 1.0)
        XCTAssertEqual(tables.count, 1)
        XCTAssertEqual(tables.first?.rows, 1)
        XCTAssertEqual(tables.first?.columns, 1)
        XCTAssertEqual(tables.first?.cells.first?.text, "A")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

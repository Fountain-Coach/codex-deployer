import XCTest
import SPSCore
import SPSTools
import Toolsmith
import SandboxRunner
import Foundation

final class SPSCoreTests: XCTestCase {
    var engine: SPSEngine!
    
    override func setUp() {
        super.setUp()
        engine = SPSEngine()
    }
    
    func testIndexValidation() {
        // Test valid index
        let validIndex = IndexRoot(documents: [
            IndexDoc(id: "doc1", fileName: "test.pdf", size: 1000)
        ])
        
        let result = engine.validateIndex(validIndex)
        XCTAssertTrue(result.ok)
        XCTAssertTrue(result.issues.isEmpty)
        
        // Test invalid index - empty ID
        let invalidIndex = IndexRoot(documents: [
            IndexDoc(id: "", fileName: "test.pdf", size: 1000)
        ])
        
        let invalidResult = engine.validateIndex(invalidIndex)
        XCTAssertFalse(invalidResult.ok)
        XCTAssertFalse(invalidResult.issues.isEmpty)
    }
    
    func testQueryFunctionality() throws {
        let index = IndexRoot(documents: [
            IndexDoc(
                id: "doc1",
                fileName: "test.pdf",
                size: 1000,
                pages: [
                    IndexPage(
                        number: 1,
                        text: "This is a test document with MIDI note information.",
                        lines: [
                            TextLine(text: "MIDI note information", x: 10, y: 20, width: 100, height: 12)
                        ]
                    )
                ]
            )
        ])
        
        let queryRequest = QueryRequest(index: index, q: "MIDI")
        let response = try engine.query(queryRequest)
        
        XCTAssertFalse(response.hits.isEmpty)
        XCTAssertEqual(response.hits.first?.docId, "doc1")
        XCTAssertEqual(response.hits.first?.page, 1)
    }
    
    func testMatrixExport() {
        let index = IndexRoot(documents: [
            IndexDoc(
                id: "doc1",
                fileName: "test.pdf",
                size: 1000,
                pages: [
                    IndexPage(
                        number: 1,
                        text: "Note On message velocity channel",
                        lines: [
                            TextLine(text: "Note On message", x: 10, y: 20, width: 100, height: 12),
                            TextLine(text: "velocity channel", x: 10, y: 40, width: 100, height: 12)
                        ]
                    )
                ]
            )
        ])
        
        let request = ExportMatrixRequest(index: index)
        let matrix = engine.exportMatrix(request)
        
        XCTAssertEqual(matrix.schemaVersion, "2.0")
        XCTAssertFalse(matrix.messages.isEmpty)
        XCTAssertFalse(matrix.terms.isEmpty)
    }
    
    func testTableDetection() {
        let index = IndexRoot(documents: [
            IndexDoc(
                id: "doc1",
                fileName: "test.pdf",
                size: 1000,
                pages: [
                    IndexPage(
                        number: 1,
                        text: "Test document",
                        lines: [
                            TextLine(text: "Note On\tVelocity\tChannel", x: 10, y: 20, width: 200, height: 12),
                            TextLine(text: "60\t100\t1", x: 10, y: 32, width: 200, height: 12)
                        ]
                    )
                ]
            )
        ])
        
        let tables = TableDetector.extractTables(from: index)
        XCTAssertFalse(tables.isEmpty)
        
        let detected = TableDetector.detect(from: index)
        XCTAssertFalse(detected.messages.isEmpty || detected.terms.isEmpty)
    }
}

final class SPSToolsTests: XCTestCase {
    var toolFactory: SPSToolFactory!
    var mockRunner: MockSandboxRunner!
    var toolsmith: Toolsmith!
    
    override func setUp() {
        super.setUp()
        mockRunner = MockSandboxRunner()
        toolsmith = Toolsmith()
        toolFactory = SPSToolFactory(toolsmith: toolsmith, runner: mockRunner)
    }
    
    func testScanToolValidation() throws {
        // Create a temporary test file
        let tempDir = FileManager.default.temporaryDirectory
        let testFile = tempDir.appendingPathComponent("test.pdf")
        try "Mock PDF content".write(to: testFile, atomically: true, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(at: testFile)
        }
        
        let request = ScanRequest(inputs: [testFile.path], includeText: true)
        let result = try toolFactory.scanTool.scan(request: request, workDirectory: tempDir)
        
        XCTAssertFalse(result.documents.isEmpty)
        XCTAssertEqual(result.documents.first?.fileName, "test.pdf")
    }
    
    func testValidationTool() throws {
        let index = IndexRoot(documents: [
            IndexDoc(id: "doc1", fileName: "test.pdf", size: 1000)
        ])
        
        let result = try toolFactory.validationTool.validate(index: index)
        XCTAssertTrue(result.ok)
    }
    
    func testQueryTool() throws {
        let index = IndexRoot(documents: [
            IndexDoc(
                id: "doc1",
                fileName: "test.pdf",
                size: 1000,
                pages: [
                    IndexPage(number: 1, text: "Test MIDI content")
                ]
            )
        ])
        
        let request = QueryRequest(index: index, q: "MIDI")
        let response = try toolFactory.queryTool.query(request: request)
        
        XCTAssertFalse(response.hits.isEmpty)
    }
    
    func testMatrixExportTool() throws {
        let index = IndexRoot(documents: [
            IndexDoc(
                id: "doc1",
                fileName: "test.pdf",
                size: 1000,
                pages: [
                    IndexPage(number: 1, text: "Note On message")
                ]
            )
        ])
        
        let request = ExportMatrixRequest(index: index)
        let matrix = try toolFactory.matrixExportTool.exportMatrix(request: request)
        
        XCTAssertEqual(matrix.schemaVersion, "2.0")
    }
}

// MARK: - Mock Classes

class MockSandboxRunner: SandboxRunner {
    func run(
        executable: String,
        arguments: [String],
        inputs: [URL],
        workDirectory: URL,
        allowNetwork: Bool,
        timeout: TimeInterval?,
        limits: CgroupLimits?
    ) throws -> SandboxResult {
        return SandboxResult(stdout: "Mock output", stderr: "", exitCode: 0)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
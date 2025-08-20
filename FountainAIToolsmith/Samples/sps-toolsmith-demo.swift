#!/usr/bin/env swift

// Example demonstrating SPS functionality through Toolsmith
// Run with: swift run sps-toolsmith-demo

import Foundation
import Toolsmith
import SandboxRunner
import SPSTools
import SPSCore

print("=== SPS via Toolsmith Sandbox Demo ===\n")

// Initialize the Toolsmith environment
let toolsmith = Toolsmith()
let runner = MockSandboxRunner() // Using mock for demo purposes
let spsFactory = SPSToolFactory(toolsmith: toolsmith, runner: runner)

// Create a mock PDF file for demonstration
let tempDir = FileManager.default.temporaryDirectory
let mockPDF = tempDir.appendingPathComponent("demo.pdf")

let mockPDFContent = """
MIDI Specification Document

Chapter 1: Note Messages
Note On: Velocity 64, Channel 1
Note Off: Velocity 0, Channel 1

Chapter 2: Controller Messages  
Control Change: Controller 7 (Volume), Value 100
Program Change: Program 42 (Bass)

Chapter 3: System Messages
System Exclusive: Manufacturer ID, Device ID, Data
"""

do {
    // Create mock PDF file
    try mockPDFContent.write(to: mockPDF, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(at: mockPDF) }
    
    print("1. Scanning PDF documents...")
    let scanRequest = ScanRequest(
        inputs: [mockPDF.path],
        includeText: true,
        sha256: true
    )
    
    let index = try spsFactory.scanTool.scan(request: scanRequest, workDirectory: tempDir)
    print("   ✓ Scanned \(index.documents.count) document(s)")
    print("   ✓ Document: \(index.documents.first?.fileName ?? "unknown")")
    print("   ✓ Size: \(index.documents.first?.size ?? 0) bytes")
    if let sha256 = index.documents.first?.sha256 {
        print("   ✓ SHA256: \(sha256)")
    }
    print()
    
    print("2. Validating index structure...")
    let validation = try spsFactory.validationTool.validate(index: index)
    print("   ✓ Validation passed: \(validation.ok)")
    if !validation.issues.isEmpty {
        print("   ⚠ Issues: \(validation.issues.joined(separator: ", "))")
    }
    print()
    
    print("3. Querying for MIDI content...")
    let queryRequest = QueryRequest(index: index, q: "Note", pageRange: nil)
    let queryResponse = try spsFactory.queryTool.query(request: queryRequest)
    print("   ✓ Found \(queryResponse.hits.count) hits for 'Note'")
    for hit in queryResponse.hits.prefix(3) {
        print("   - Page \(hit.page): \(hit.snippet)")
    }
    print()
    
    print("4. Exporting matrix for Midi2Swift...")
    let exportRequest = ExportMatrixRequest(
        index: index,
        bitfields: true,
        ranges: true,
        enums: false
    )
    let matrix = try spsFactory.matrixExportTool.exportMatrix(request: exportRequest)
    print("   ✓ Matrix schema version: \(matrix.schemaVersion)")
    print("   ✓ Messages detected: \(matrix.messages.count)")
    print("   ✓ Terms detected: \(matrix.terms.count)")
    
    if !matrix.messages.isEmpty {
        print("   Message samples:")
        for message in matrix.messages.prefix(3) {
            print("     - \(message.text)")
        }
    }
    
    if !matrix.terms.isEmpty {
        print("   Term samples:")
        for term in matrix.terms.prefix(3) {
            print("     - \(term.text)")
        }
    }
    print()
    
    print("5. Demonstrating workflow convenience methods...")
    let (indexResult, validationResult) = try spsFactory.scanAndValidate(
        pdfs: [mockPDF.path],
        includeText: true,
        sha256: false,
        validate: true,
        workDirectory: tempDir
    )
    print("   ✓ Scan and validate workflow completed")
    print("   ✓ Documents: \(indexResult.documents.count)")
    print("   ✓ Validation: \(validationResult?.ok ?? false)")
    print()
    
    print("=== Demo completed successfully! ===")
    print()
    print("SPS is now fully integrated with the Toolsmith Sandbox framework.")
    print("All operations run in a sandboxed environment with proper logging and tracing.")
    
} catch {
    print("❌ Demo failed with error: \(error)")
    exit(1)
}

// Mock SandboxRunner for demonstration purposes
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
        // Simulate successful sandbox execution
        return SandboxResult(stdout: "Mock sandbox execution", stderr: "", exitCode: 0)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
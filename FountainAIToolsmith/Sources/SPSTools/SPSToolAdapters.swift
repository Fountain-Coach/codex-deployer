import Foundation
import Toolsmith
import SandboxRunner
import SPSCore

// MARK: - SPS Scan Tool Adapter

public struct SPSScanTool {
    public let toolsmith: Toolsmith
    public let runner: SandboxRunner
    public let engine: SPSEngine
    
    public init(toolsmith: Toolsmith, runner: SandboxRunner) {
        self.toolsmith = toolsmith
        self.runner = runner
        self.engine = SPSEngine()
    }
    
    public func scan(request: ScanRequest, workDirectory: URL) throws -> IndexRoot {
        // Validate input files exist
        for inputPath in request.inputs {
            let url = URL(fileURLWithPath: inputPath)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw SPSToolError.fileNotFound(inputPath)
            }
        }
        
        var result: IndexRoot!
        try toolsmith.run(tool: "sps-scan") {
            // Execute scan in sandbox environment
            result = try engine.scan(
                pdfs: request.inputs,
                includeText: request.includeText,
                sha256: request.sha256
            )
        }
        
        return result
    }
}

// MARK: - SPS Index Validation Tool Adapter

public struct SPSIndexValidationTool {
    public let toolsmith: Toolsmith
    public let runner: SandboxRunner
    public let engine: SPSEngine
    
    public init(toolsmith: Toolsmith, runner: SandboxRunner) {
        self.toolsmith = toolsmith
        self.runner = runner
        self.engine = SPSEngine()
    }
    
    public func validate(index: IndexRoot) throws -> ValidationResult {
        var result: ValidationResult!
        try toolsmith.run(tool: "sps-validate") {
            result = engine.validateIndex(index)
        }
        return result
    }
}

// MARK: - SPS Query Tool Adapter

public struct SPSQueryTool {
    public let toolsmith: Toolsmith
    public let runner: SandboxRunner
    public let engine: SPSEngine
    
    public init(toolsmith: Toolsmith, runner: SandboxRunner) {
        self.toolsmith = toolsmith
        self.runner = runner
        self.engine = SPSEngine()
    }
    
    public func query(request: QueryRequest) throws -> QueryResponse {
        var result: QueryResponse!
        try toolsmith.run(tool: "sps-query") {
            result = try engine.query(request)
        }
        return result
    }
}

// MARK: - SPS Matrix Export Tool Adapter

public struct SPSMatrixExportTool {
    public let toolsmith: Toolsmith
    public let runner: SandboxRunner
    public let engine: SPSEngine
    
    public init(toolsmith: Toolsmith, runner: SandboxRunner) {
        self.toolsmith = toolsmith
        self.runner = runner
        self.engine = SPSEngine()
    }
    
    public func exportMatrix(request: ExportMatrixRequest) throws -> Matrix {
        var result: Matrix!
        try toolsmith.run(tool: "sps-export-matrix") {
            result = engine.exportMatrix(request)
        }
        return result
    }
}

// MARK: - Unified SPS Tool Factory

public struct SPSToolFactory {
    public let toolsmith: Toolsmith
    public let runner: SandboxRunner
    
    public init(toolsmith: Toolsmith, runner: SandboxRunner) {
        self.toolsmith = toolsmith
        self.runner = runner
    }
    
    public var scanTool: SPSScanTool {
        SPSScanTool(toolsmith: toolsmith, runner: runner)
    }
    
    public var validationTool: SPSIndexValidationTool {
        SPSIndexValidationTool(toolsmith: toolsmith, runner: runner)
    }
    
    public var queryTool: SPSQueryTool {
        SPSQueryTool(toolsmith: toolsmith, runner: runner)
    }
    
    public var matrixExportTool: SPSMatrixExportTool {
        SPSMatrixExportTool(toolsmith: toolsmith, runner: runner)
    }
}

// MARK: - Error Types

public enum SPSToolError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidInput(String)
    case processingError(String)
    case validationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .processingError(let message):
            return "Processing error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        }
    }
}

// MARK: - Convenience Extensions

extension SPSToolFactory {
    /// Execute a complete scan workflow: scan PDFs and optionally validate the result
    public func scanAndValidate(
        pdfs: [String],
        includeText: Bool = false,
        sha256: Bool = false,
        validate: Bool = true,
        workDirectory: URL
    ) throws -> (index: IndexRoot, validation: ValidationResult?) {
        
        let scanRequest = ScanRequest(
            inputs: pdfs,
            includeText: includeText,
            sha256: sha256
        )
        
        let index = try scanTool.scan(request: scanRequest, workDirectory: workDirectory)
        
        let validationResult = validate ? try validationTool.validate(index: index) : nil
        
        return (index: index, validation: validationResult)
    }
    
    /// Execute a complete matrix export workflow with validation
    public func exportMatrixWithValidation(
        index: IndexRoot,
        bitfields: Bool = false,
        ranges: Bool = false,
        enums: Bool = false
    ) throws -> (matrix: Matrix, validation: ValidationResult) {
        
        let validation = try validationTool.validate(index: index)
        
        guard validation.ok else {
            throw SPSToolError.validationError("Index validation failed: \(validation.issues.joined(separator: ", "))")
        }
        
        let exportRequest = ExportMatrixRequest(
            index: index,
            bitfields: bitfields,
            ranges: ranges,
            enums: enums
        )
        
        let matrix = try matrixExportTool.exportMatrix(request: exportRequest)
        
        return (matrix: matrix, validation: validation)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
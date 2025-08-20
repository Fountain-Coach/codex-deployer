# SPS Integration with FountainAI Toolsmith

This document describes how the Semantic PDF Scanner (SPS) has been refactored to provide tools via the Toolsmith Sandbox framework instead of operating as a standalone service.

## Architecture Overview

SPS functionality is now provided through the following components within `FountainAIToolsmith`:

### Core Modules

- **SPSCore**: Contains the core data models and processing engine
  - `SPSModels.swift`: Data structures for indices, queries, matrices, etc.
  - `SPSEngine.swift`: Core PDF processing and analysis logic
  - `TableDetector.swift`: Table detection and matrix extraction functionality

- **SPSTools**: Toolsmith-compatible tool adapters
  - `SPSToolAdapters.swift`: Tool wrappers that integrate SPS with the sandbox framework

### Available Tools

The following SPS operations are now available as Toolsmith tools:

1. **sps-scan**: Scan PDFs and produce semantic indices
2. **sps-validate**: Validate index structure
3. **sps-query**: Query indices for specific content
4. **sps-export-matrix**: Export Midi2Swift-compatible matrices

## Usage Examples

### Basic SPS Tool Factory Usage

```swift
import Toolsmith
import SandboxRunner
import SPSTools
import SPSCore

// Initialize Toolsmith components
let toolsmith = Toolsmith()
let runner = BwrapRunner() // or other SandboxRunner implementation
let spsFactory = SPSToolFactory(toolsmith: toolsmith, runner: runner)

// Scan PDFs
let scanRequest = ScanRequest(
    inputs: ["path/to/document.pdf"],
    includeText: true,
    sha256: true
)
let workDir = FileManager.default.temporaryDirectory
let index = try spsFactory.scanTool.scan(request: scanRequest, workDirectory: workDir)

// Validate the index
let validation = try spsFactory.validationTool.validate(index: index)
print("Validation passed: \(validation.ok)")

// Query the index
let queryRequest = QueryRequest(index: index, q: "MIDI", pageRange: "1-5")
let queryResponse = try spsFactory.queryTool.query(request: queryRequest)
print("Found \(queryResponse.hits.count) hits")

// Export matrix
let exportRequest = ExportMatrixRequest(index: index, bitfields: true)
let matrix = try spsFactory.matrixExportTool.exportMatrix(request: exportRequest)
print("Matrix contains \(matrix.messages.count) messages and \(matrix.terms.count) terms")
```

### Convenience Workflows

```swift
// Scan and validate in one operation
let (index, validation) = try spsFactory.scanAndValidate(
    pdfs: ["document1.pdf", "document2.pdf"],
    includeText: true,
    sha256: true,
    validate: true,
    workDirectory: workDir
)

// Export matrix with validation
let (matrix, validationResult) = try spsFactory.exportMatrixWithValidation(
    index: index,
    bitfields: true,
    ranges: true,
    enums: true
)
```

## Integration with Toolsmith Sandbox

SPS operations now run within the Toolsmith sandbox environment, providing:

- **Isolation**: PDF processing runs in a controlled sandbox environment
- **Logging**: All operations are logged with request IDs and duration metrics
- **Tracing**: Optional OpenTelemetry integration for distributed tracing
- **Resource Limits**: Configurable memory, CPU, and process limits

## Tool Manifest Updates

The main `tools.json` manifest has been updated to include SPS operations:

```json
{
  "tools": {
    "sps": "Semantic PDF Scanner via Toolsmith"
  },
  "operations": [
    "sps-scan",
    "sps-validate", 
    "sps-query",
    "sps-export-matrix"
  ]
}
```

## OpenAPI Specification

The SPS OpenAPI specification (`sps.openapi.yml`) has been moved to:
`FountainAIToolsmith/Sources/SPSTools/Resources/sps.openapi.yml`

This maintains compatibility with existing tools-factory integration while providing the backing implementation through Toolsmith.

## Migration Benefits

1. **Unified Architecture**: SPS is now part of the broader Toolsmith ecosystem
2. **Sandbox Security**: PDF processing runs in isolated environments
3. **Better Observability**: Consistent logging and tracing across all tools
4. **Resource Management**: Proper limits and cleanup for PDF operations
5. **Simplified Deployment**: No need for separate SPS service deployment

## Testing

All SPS functionality includes comprehensive tests:

- Core functionality tests in `SPSCoreTests`
- Tool adapter tests in `SPSToolsTests`
- Integration tests with mock sandbox runners

Run tests with:
```bash
cd FountainAIToolsmith
swift test --filter SPSTests
```

## Backward Compatibility

While the implementation has moved to Toolsmith, the OpenAPI interface remains the same, ensuring compatibility with existing integrations that expect SPS endpoints.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
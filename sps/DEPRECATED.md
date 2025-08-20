# ⚠️ DEPRECATED: SPS Directory

**This directory is deprecated as of the refactoring to integrate SPS with FountainAI Toolsmith.**

## New Location

SPS functionality has been moved to `FountainAIToolsmith` and is now available as:

- **SPSCore**: Core functionality in `FountainAIToolsmith/Sources/SPSCore/`
- **SPSTools**: Toolsmith integration in `FountainAIToolsmith/Sources/SPSTools/`

## Migration Guide

### Old Usage (Deprecated)
```bash
cd sps
swift build
./.build/debug/sps scan input.pdf --out index.json --include-text
```

### New Usage (Recommended)
```swift
import SPSTools
import SPSCore
import Toolsmith
import SandboxRunner

let toolsmith = Toolsmith()
let runner = BwrapRunner()
let spsFactory = SPSToolFactory(toolsmith: toolsmith, runner: runner)

let request = ScanRequest(inputs: ["input.pdf"], includeText: true)
let index = try spsFactory.scanTool.scan(request: request, workDirectory: workDir)
```

## Documentation

See the complete integration guide at:
- `/docs/sps-toolsmith-integration.md`
- `/FountainAIToolsmith/Samples/sps-toolsmith-demo.swift`

## Timeline

- **Current**: This directory remains for reference but is no longer maintained
- **Future**: This directory will be removed in a future release

## Benefits of Migration

1. **Sandbox Security**: SPS operations run in isolated environments
2. **Better Observability**: Consistent logging and tracing
3. **Resource Management**: Proper limits and cleanup
4. **Unified Architecture**: Part of the broader Toolsmith ecosystem

For questions about migration, see the documentation or examples in the FountainAIToolsmith package.
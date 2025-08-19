# FountainAIToolsmith in Gateway/Codex Orchestration

This guide shows how the Gateway/Codex loop imports and drives `FountainAIToolsmith` to execute sandboxed tools.

## Importing and Instantiating

Add the package to `Package.swift` and import the libraries in your orchestrator:

```swift
.package(path: "./FountainAIToolsmith")
```

```swift
import Toolsmith
import SandboxRunner

let toolsmith = Toolsmith()
let runner = BwrapRunner()
```

## Tool Call Lifecycle

The snippet below demonstrates the full `start → run → shutdown` flow of a tool call.

```swift
import Toolsmith
import SandboxRunner
import Foundation

let work = FileManager.default.temporaryDirectory.appendingPathComponent("work")
try FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)

let toolsmith = Toolsmith()
let runner = BwrapRunner()

defer { try? FileManager.default.removeItem(at: work) }

let requestID = toolsmith.run(tool: "echo") {
    let result = try runner.run(
        executable: "/bin/echo",
        arguments: ["hello"],
        inputs: [],
        workDirectory: work,
        allowNetwork: false,
        timeout: 5,
        limits: nil
    )
    print(result.stdout)
}
```

## Client Generation

Run `Scripts/generate-toolsmith-client.swift` to regenerate the `ToolsmithAPI` client from the shared `tools-factory.yml` spec. The generator copies the `Client/tools-factory` output into `FountainAIToolsmith/Sources/ToolsmithAPI`, preserving operation names like `list_tools` and `register_openapi` so interfaces mirror the Tools Factory contract and avoid naming conflicts.

## Smoke Test

Verify an orchestrator ↔ sandbox round-trip with:

```bash
Scripts/toolsmith-smoke-test.sh
```

> © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

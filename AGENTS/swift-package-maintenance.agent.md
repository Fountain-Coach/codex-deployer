# Swift Package Maintenance Agent

## 🧠 Purpose
Guide Codex in fixing recurring Swift package errors documented in [docs/swift_package_error_report.md](../docs/swift_package_error_report.md).

## 📋 Tasks
- Detect missing or incorrect `library` products in `Package.swift` manifests.
- Ensure package names remain consistent across repositories.
- Add compile-time tests for newly added packages.

## 🛠️ Prompt Instruction for Codex
````swift
// Codex instruction: SwiftPackageMaintenance
// 1. Scan commit messages for patterns like "missing package product" or "compile-time errors".
// 2. Check `Package.swift` manifests for the expected `products` definitions.
// 3. If a package was renamed, update any dependent packages accordingly.
// 4. Verify `swift build` and `swift test -v` succeed for all targets.
````

`````
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
`````

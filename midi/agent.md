# MIDI 2 Development Agent

**Last Updated:** August 12, 2025
**Scope:** `midi/` and generated Swift MIDI 2 modules
**Purpose:** Guide conversion of the official MIDI 2.0 specification into machine-readable data models using the SPS API and surface them as Swift Package Manager libraries.

## 🎯 Tasks
- Use the SPS parsing pipeline under `/sps` to ingest MIDI 2.0 specification documents placed in `midi/specs/`.
- Queue long-running scans through `SPSJobQueue` and poll `status` for progress.
- Emit normalized machine-readable models to `midi/models/`.
- Generate Swift sources for a `MIDI2` package under `Sources/MIDI2` driven by the data models.
- Expose the package via `Package.swift` and provide corresponding tests under `Tests/MIDI2Tests`.
- Keep artifacts reproducible: regenerate instead of hand-editing when specs change.
- Verify all changes with `swift test`.

## 📝 Style
- Follow repository-wide SwiftLint rules.
- Prefer value types and explicit access control in Swift code.

## 🗂 Task Matrix

| # | Feature / Component        | Files / Area                              | Action | Problems | Results | Status |
|---|---------------------------|-------------------------------------------|--------|----------|---------|--------|
| 1 | Spec ingestion pipeline   | `midi/specs/`, `sps/*`                     | Ingest MIDI 2.0 specification documents via SPS parsing pipeline using `SPSJobQueue` for asynchronous processing | – | index regenerated via `--wait` queue | DONE |
| 2 | Data model generation     | `midi/models/`                             | Emit normalized machine-readable models from ingested specs | – | messages, enums, bitfields, ranges regenerated | DONE |
| 3 | Swift package scaffolding | `Sources/MIDI2/*`, `Package.swift`         | Generate Swift sources for a `MIDI2` module and expose via Swift Package Manager | – | Package and tests scaffolded | DONE |
| 4 | Test suite                | `Tests/MIDI2Tests/*`                       | Provide tests covering generated MIDI 2 functionality | – | Basic index loading test added | TODO |
| 5 | Reproducibility tooling   | `midi/*`                                   | Ensure artifacts are reproducible and regeneratable when specs change | – | – | TODO |
| 6 | Verification              | `swift test`                               | Run full `swift test` after changes | – | all tests passed | DONE |
| 7 | Job queue reliability     | `sps/Sources/SPSCLI/JobQueue.swift`        | Persist jobs synchronously and provide worker or `--wait` mode | – | sync persistence and `--wait` flag implemented | DONE |


> © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

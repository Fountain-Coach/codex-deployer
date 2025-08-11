# MIDI 2 Development Agent

**Last Updated:** August 11, 2025  
**Scope:** `midi/` and generated Swift MIDI 2 modules  
**Purpose:** Guide conversion of the official MIDI 2.0 specification into machine-readable data models using the SPS API and surface them as Swift Package Manager libraries.

## 🎯 Tasks
- Use the SPS parsing pipeline under `/sps` to ingest MIDI 2.0 specification documents placed in `midi/specs/`.
- Emit normalized machine-readable models to `midi/models/`.
- Generate Swift sources for a `MIDI2` package under `Sources/MIDI2` driven by the data models.
- Expose the package via `Package.swift` and provide corresponding tests under `Tests/MIDI2Tests`.
- Keep artifacts reproducible: regenerate instead of hand-editing when specs change.
- Verify all changes with `swift test`.

## 📝 Style
- Follow repository-wide SwiftLint rules.
- Prefer value types and explicit access control in Swift code.

## 🗂 Task Matrix

| # | Feature / Component        | Files / Area                              | Action                                                                                           | Status |
|---|---------------------------|-------------------------------------------|--------------------------------------------------------------------------------------------------|--------|
| 1 | Spec ingestion pipeline   | `midi/specs/`, `sps/*`                     | Ingest MIDI 2.0 specification documents via SPS parsing pipeline                                 | ✅     |
| 2 | Data model generation     | `midi/models/`                             | Emit normalized machine-readable models from ingested specs                                      | ✅   |
| 3 | Swift package scaffolding | `Sources/MIDI2/*`, `Package.swift`         | Generate Swift sources for a `MIDI2` module and expose via Swift Package Manager                 | TODO   |
| 4 | Test suite                | `Tests/MIDI2Tests/*`                       | Provide tests covering generated MIDI 2 functionality                                            | TODO   |
| 5 | Reproducibility tooling   | `midi/*`                                   | Ensure artifacts are reproducible and regeneratable when specs change                            | TODO   |
| 6 | Verification              | `swift test`                               | Run full `swift test` after changes                                                              | TODO   |

> © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

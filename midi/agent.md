# MIDI 2 Development Agent

**Last Updated:** August 12, 2025
**Scope:** `midi/` and generated Swift MIDI 2 modules
**Purpose:** Guide conversion of the official MIDI 2.0 specification into machine-readable data models using the SPS API and surface them as Swift Package Manager libraries.

## 🎯 Tasks
- Ensure SPS toolchain prerequisites are installed (`make -C sps deps`) so PDFium and other requirements are available.
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

| # | Feature | Area | Action | Problems | Results | Status |
|---|---------|------|--------|----------|---------|--------|
| 1 | SPS toolchain setup | `sps/` | Install deps via `make -C sps deps` | — | — | TODO |
| 2 | Spec ingestion pipeline | `midi/specs/`, `sps/*` | Ingest specs via `sps scan --wait` | — | — | TODO |
| 3 | Data model generation | `midi/models/` | Emit normalized models | — | — | TODO |
| 4 | Swift package scaffolding | `Sources/MIDI2/*`, `Package.swift` | Generate `MIDI2` module | — | — | TODO |
| 5 | Test suite | `Tests/MIDI2Tests/*` | Cover generated functionality | — | — | TODO |
| 6 | Reproducibility tooling | `midi/*` | Keep artifacts reproducible | — | — | TODO |
| 7 | Verification | `swift test` | Run full test suite | — | — | TODO |
| 8 | Job queue reliability | `sps/Sources/SPSCLI/JobQueue.swift` | Ensure queue persists jobs & wait mode | — | — | TODO |


> © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

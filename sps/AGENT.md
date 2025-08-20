# Semantic PDF Scanner (SPS) • AGENT.md

## Deprecation Notice
The Semantic PDF Scanner (SPS) service is deprecated and scheduled for removal on **2025-11-01**. Development has ceased and existing users should migrate to alternative tooling.

## Repository map (for `sps/`)
- `Package.swift` — SwiftPM manifest (Swift 6)
- `Sources/SPSCLI/` — the CLI target
  - `main.swift` — subcommands: `scan`, `index`, `query`, `export-matrix`
  - `Resources/` — templates and built-in prompts (kept empty for now)
- `openapi/sps.openapi.yml` — OpenAPI describing the CLI’s capabilities for client generators
- `Tests/SPSCLITests/` — unit tests for helper logic
  - `Samples/` — annotated sample PDFs for extraction and table detection
- `AGENT.md` — this file
- `.gitignore`, `Makefile`

## Hard constraints
1. **Swift-only** for the CLI. No Python/Java runtimes. Native dependencies must be C/Rust/Go friendly if/when added.
2. CLI must remain **hermetic**: it should run with just Swift toolchains and optional system libraries (CGPDF on macOS).
3. OpenAPI is **source of truth** for automation and integration with Fountain tools‑factory.
4. Deterministic outputs (same inputs → same index JSON).

## MVP scope (what “works today”)
- `scan` accepts one or more PDFs and produces a basic JSON index with:
  - document metadata (file name, size, optional SHA256)
  - page stubs (page count placeholder)
  - extracted text (placeholder; ready for future extractors)
  - optional page filtering via `--page-range`
- `index` echoes the index location and validates structure.
- `query` does simple keyword filtering over extracted text (case-insensitive contains) and supports `--page-range`.
- `export-matrix` creates a **Midi2Swift-friendly** skeleton (`messages: []`, `terms: []`) and can run validation hooks with `--validate`.

> The actual PDF text extraction is intentionally stubbed in Swift for portability. Real extraction backends:
> - macOS: **CGPDF** (CoreGraphics) or **PDFKit** bridge (C-based)
> - Cross‑platform: **PDFium** (C) via Swift wrapper, optional **Tesseract** for OCR (C++)

## Roadmap (incremental)
1. **Text extraction backends** (CGPDF first, PDFium wrapper second).
2. **Table detector** (rule-based over text + coordinates → semantic tables).
3. **Entity linker** (terms ↔ definitions; messages ↔ normative sections).
4. **Matrix exporter v2** (bitfields, ranges, enums; feeds Midi2Swift SwiftGen).
5. **Verifier hooks** (coverage, reserved-bit invariants, golden vectors cross-check) – basic hooks shipped behind `--validate`.

## CLI overview
```
sps scan <pdf...> --out <index.json> [--include-text] [--sha256] [--page-range A-B]
sps index validate <index.json>
sps query <index.json> --q "<term|regex>" [--page-range A-B]
sps export-matrix <index.json> --out spec/matrix.json [--validate]
```

### Exit codes
- `0` success
- `1` generic failure
- `2` usage/args error
- `3` validation failed

## OpenAPI contract (summary)
- `POST /scan` → body: file(s) or URLs, opts (`includeText`, `sha256`). Returns `Index` JSON.
- `POST /index/validate` → body: `Index`. Returns `{ok: bool, issues:[...]}`.
- `POST /query` → body: `Index + query`. Returns matched spans.
- `POST /export/matrix` → body: `Index`. Returns Midi2Swift‑shaped `matrix.json`.

See `openapi/sps.openapi.yml` for full schema. The CLI mirrors these operations for local use and CI steps.

## Quality gates
- Unit tests green (`swift test`).
- Indices are deterministic (stable key ordering, sorted arrays where applicable).
- No `.build/` or `.swiftpm/` committed.
- OpenAPI and CLI stay in sync (version bump when the contract changes).

## Typical workflow
```
# 1) Build
swift build -c release

# 2) Scan PDFs into an index
.build/release/sps scan spec/sources/midi2/*.pdf --out spec/index.json --include-text --page-range 1-3 --sha256

# 3) Validate + quick query
.build/release/sps index validate spec/index.json
.build/release/sps query spec/index.json --q "Note On" --page-range 10-12

# 4) Export matrix for Midi2Swift generators
.build/release/sps export-matrix spec/index.json --out spec/matrix.json --validate
```

The `--validate` flag runs coverage analysis and reserved-bit checks.
It emits a report alongside the matrix at `spec/matrix.json.validation.json`.
Sample report:

```
{
  "coveragePassed": true,
  "reservedBitsPassed": true,
  "issues": []
}
```

## Non-goals (for now)
- Full OCR pipeline (planned via optional Tesseract backend).
- Embedded image/vector extraction beyond text needed for tables.
- Shipping dynamic system installers; keep dependencies explicit.

## Definition of Done (per feature)
- CLI subcommand implemented and covered by unit tests.
- OpenAPI updated and version bumped.
- Determinism proven (two runs → identical outputs).
- Works on macOS 14+ and Ubuntu 24.04 (Swift 6).

---

### Notes for Midi2Swift integration
- The produced `matrix.json` must slot into `tools/MatrixBuilder` without manual edits.
- When `STRICT_FULL_SPEC=1` in downstream CI, missing fields should surface as validation errors, not crashes.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

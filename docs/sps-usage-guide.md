# SPS Usage Guide

This guide demonstrates end-to-end workflows with the Semantic PDF Scanner CLI, including page range queries and validation hooks.

## 0. Install PDF dependencies
Before building, install required PDF libraries (PDFium, Tesseract) using the helper script:
```bash
make -C sps deps
```

## 1. Scan PDFs into an index
```bash
swift build -c release
.build/release/sps scan sps/Samples/extraction_sample.pdf sps/Samples/table_detection_sample.pdf --out index.json --include-text --page-range 1-2
```

## 1a. Run scans asynchronously
The `scan` command now enqueues work and returns a ticket immediately:
```bash
.build/release/sps scan sps/Samples/extraction_sample.pdf --out async-index.json
# -> SPS: enqueued scan job -> <ticket>
```

Check progress with rotating motivational messages:
```bash
.build/release/sps status <ticket>
```
States include `pending`, `running`, `completed`, and `failed`. When completed, the status command prints the result path.

## 2. Validate the generated index
```bash
.build/release/sps index validate index.json
```

## 3. Query the index with page ranges
```bash
.build/release/sps query index.json --q "annotated" --page-range 1
```

## 4. Export a matrix with validation hooks
```bash
.build/release/sps export-matrix index.json --out matrix.json --validate
```
The `--page-range` flag accepts comma-separated ranges such as `1-3,5`,
while `--validate` emits `matrix.json.validation.json` summarizing coverage and reserved-bit checks.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

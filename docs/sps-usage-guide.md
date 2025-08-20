> ⚠️ **Warning:** The Semantic PDF Scanner is frozen. Use the Toolsmith sandbox workflow instead (see [Toolsmith orchestration guide](toolsmith-orchestration.md)).

# SPS Usage Guide

This guide demonstrates end-to-end PDF processing using the sandboxed Tool Server and `toolsmith-cli`.

## 0. Launch the sandbox Tool Server
```bash
swift run ToolServer --port 8080 &
export TOOLSERVER_URL=http://localhost:8080
```

## 1. Scan PDFs into an index
```bash
toolsmith-cli pdf-scan sps/Samples/extraction_sample.pdf sps/Samples/table_detection_sample.pdf > index.json
```

## 2. Validate the generated index
```bash
toolsmith-cli pdf-index-validate index.json
```

## 3. Query the index with page ranges
```bash
toolsmith-cli pdf-query index.json annotated 1
```

## 4. Export a matrix with validation hooks
```bash
toolsmith-cli pdf-export-matrix index.json > matrix.json
```
The `pdf-query` command accepts an optional page range such as `1-3,5`, and `pdf-export-matrix` produces a `matrix.json` compatible with Midi2Swift generators.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

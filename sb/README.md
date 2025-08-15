# Semantic Browser & Dissector (sb)

Swift 6.1 command line tool that snapshots web pages, extracts semantic structure, and optionally indexes the results to Typesense.

## CLI Usage

### Browse

```bash
swift run sb browse --url https://example.com --mode quick --out ./out
```

Fetch a page, produce a `snapshot.json`, and emit an optional `analysis.json` when `--mode` is not `quick`.

### Analyze

```bash
swift run sb analyze --snapshot ./out/snapshot.json --mode deep --out ./out
```

Generate a new analysis from an existing snapshot.

### Index

```bash
swift run sb index --analysis ./out/analysis.json \
    --typesense-url http://localhost:8108 \
    --typesense-key $TYPESENSE_API_KEY
```

Upsert analysis documents into Typesense collections.

## OpenAPI

The optional HTTP kernel for this service is described by [`openapi/semantic-browser.openapi.yaml`](openapi/semantic-browser.openapi.yaml).

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

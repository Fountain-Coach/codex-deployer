# Streaming Schemas and Client Usage

This page consolidates the Server‑Sent Events (SSE) streams provided by the FountainAI services and documents their payload schemas, endpoint shapes, and client usage examples.

## Overview

FountainAI services emit SSE for certain operations to deliver progressive updates:

- Awareness history stream
  - Endpoint: `GET /corpus/history/stream?sse=1`
  - Events: `tick` (JSON payload), `: heartbeat` (comment), `complete` (empty JSON `{}`)
  - OpenAPI: `openapi/v1/baseline-awareness.yml`
    - `components.schemas.AwarenessStreamEvent`
    - `components.schemas.AwarenessTickData` (status="started", kind="tick")
    - `components.schemas.AwarenessCompleteData` (empty object)

- Bootstrap baseline stream
  - Endpoint: `POST /bootstrap/baseline?sse=1`
  - Events: `drift`, `patterns` (JSON payloads), `: heartbeat` (comment), `complete` (empty JSON `{}`)
  - OpenAPI: `openapi/v1/bootstrap.yml`
    - `components.schemas.StreamEvent` (union discriminated by `status`)
    - `components.schemas.StreamStartedData` (status="started")
    - `components.schemas.StreamCompleteData` (empty object)
    - `components.schemas.StreamPayload` (union discriminated by `kind`)
    - `components.schemas.StreamDriftData` (status, kind="drift")
    - `components.schemas.StreamPatternsData` (status, kind="patterns")

Gateway proxies these streams transparently when routes are configured in `Configuration/routes.json`.

## Event Sequences

- Awareness (history stream)
  1) `event: tick` with data `{"status":"started","kind":"tick"}`
  2) `: heartbeat` comment(s)
  3) `event: complete` with data `{}`

- Bootstrap (baseline stream)
  1) `event: drift` with data `{"status":"started","kind":"drift"}`
  2) `event: patterns` with data `{"status":"started","kind":"patterns"}`
  3) `: heartbeat` comment(s)
  4) `event: complete` with data `{}`

## Schemas (selected)

See the YAML files for full definitions and discriminator mappings.

- Awareness
  - `AwarenessStreamEvent` oneOf `AwarenessTickData | AwarenessCompleteData` with discriminator `kind`.
  - `AwarenessTickData`:
    - `status: string (enum: [started])`
    - `kind: string (const: tick)`
  - `AwarenessCompleteData`: empty object

- Bootstrap
  - `StreamEvent` oneOf `StreamStartedData | StreamCompleteData` with discriminator `status`.
  - `StreamStartedData`:
    - `status: string (enum: [started])`
  - `StreamCompleteData`: empty object
  - `StreamPayload` oneOf `StreamDriftData | StreamPatternsData` with discriminator `kind`.
  - `StreamDriftData`:
    - `status: string (enum: [started])`
    - `kind: string (const: drift)`
  - `StreamPatternsData`:
    - `status: string (enum: [started])`
    - `kind: string (const: patterns)`

## Curl Examples

Awareness (direct):

```
curl -N "http://localhost:8081/corpus/history/stream?sse=1"
```

Bootstrap via Gateway:

```
curl -N -H "Content-Type: application/json" \
  -d '{"corpusId":"c1","baselineId":"b1","content":"hello"}' \
  "http://localhost:8080/bootstrap/baseline?sse=1"
```

## sse-client CLI

A small CLI is included to explore streams more comfortably.

Usage:

```
swift run sse-client [--event name]* [--pretty] [--field path] \
                     [--format text|json|raw] [--timeout secs] [--max-retries n] \
                     <url>
```

Examples:

- Awareness (tick event, JSON minified):
  ```
  swift run sse-client --event tick --format json \
    http://localhost:8080/awareness/corpus/history/stream?sse=1
  ```

- Bootstrap (only patterns payloads, pretty JSON):
  ```
  swift run sse-client --event patterns --pretty \
    http://localhost:8080/bootstrap/baseline?sse=1
  ```

- Extract a specific field (JSONPath-like):
  ```
  # tick status
  swift run sse-client --event tick --field $.status --format json \
    http://localhost:8080/awareness/corpus/history/stream?sse=1
  
  # wildcard over array values (if payload contains arrays)
  swift run sse-client --field $.events[*].type --format json <url>
  
  # simple filter (items{key=value}) to select array elements
  swift run sse-client --field $.items{type=baseline} --format json <url>
  ```

- Raw mode (show exactly what the server sends):
  ```
  swift run sse-client --format raw http://localhost:8082/bootstrap/baseline?sse=1
  ```

Notes:
- `--timeout` sets a request timeout (in seconds) and the client will reconnect with exponential backoff.
- `--max-retries` stops reconnecting after N attempts (defaults to unlimited if not set).
- `--field` supports basic paths like `$.a.b[0]`, wildcard `[*]`, and a simple array filter `{key=value}`. If the extraction fails, the full JSON payload is printed.

## Gateway Notes

If you are proxying via the Gateway, ensure routes are configured in `Configuration/routes.json`. Example snippet:

```
[
  {
    "id": "awareness",
    "path": "/awareness",
    "target": "http://127.0.0.1:8081",
    "methods": ["GET"],
    "proxyEnabled": true
  },
  {
    "id": "bootstrap",
    "path": "/bootstrap",
    "target": "http://127.0.0.1:8082",
    "methods": ["GET","POST"],
    "proxyEnabled": true
  }
]
```

If you protect streams with `RoleGuardPlugin`, see `docs/gateway-roleguard.md` for configuring required roles/scopes and method restrictions.

---

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


# 🧠 FountainAI Root Agent Manifest

Last Updated: August 26, 2025

Scope: Repository self-improvement, spec→code alignment, and runtime orchestration.  
Identity: Swift 6 transparent reasoning engine; OpenAPI is the constitutional source of truth; MIDI‑CI is the discovery/observability fabric.

---

## Why The Previous Manifest Was Outdated

- Over-claimed status: Marked many services as ✅ that do not exist as code (e.g., Function Caller, Persistence, Planner, Baseline Awareness, Semantic Browser).
- Incorrect paths: Referenced files under non-existent trees (e.g., `Sources/openapi/Generated/...`). This repo uses `libs/*`, `apps/*`, and `openapi/*`.
- Drift from reality: Claimed DNS HTTP CRUD and multiple CI features not present in the current codebase.
- Corrupted content: A stray table row leaked to the top and bottom of the document.
- Conflated concerns: Mixed product identity, long task matrix, and per-run instructions in one place without machine-verifiable links to code/tests.

---

## Repository Topography (Current)

- Apps: `gateway-server`, `publishing-frontend`, `flexctl`, `clientgen-service`, `tools-factory-server`
- Gateway Plugins (code): Auth, LLM, RateLimiter, BudgetBreaker, PayloadInspection, DestructiveGuardian, SecuritySentinel
- Libraries: `FountainCodex` (OpenAPI loader, model/server generators, DNS engine, HTTP runtime), `PublishingFrontend`, `MIDI2*`, `ToolServer`, `ResourceLoader`
- OpenAPI: `openapi/v1/*`, `openapi/v2/llm-gateway.yml`, `openapi/typesense.yml`
- Tests: DNS, MIDI2, Gateway app integration, ToolServer, client generation, SSE over MIDI

---

## Spec → Code Status Snapshot

| Service/Plugin | Spec | Code | Status |
| --- | --- | --- | --- |
| Gateway (mgmt, health, routes) | `openapi/v1/gateway.yml` | `apps/GatewayServer` | Implemented (core + routing) |
| LLM Gateway | `openapi/v2/llm-gateway.yml` | `libs/GatewayPlugins/LLMGatewayPlugin` | Partial (some handlers exist) |
| Auth Plugin | `openapi/v1/auth-gateway.yml` | `libs/GatewayPlugins/AuthGatewayPlugin` | Implemented |
| Rate Limiter Plugin | `openapi/v1/rate-limiter-gateway.yml` | `libs/GatewayPlugins/RateLimiterGatewayPlugin` | Implemented |
| Budget Breaker Plugin | `openapi/v1/budget-breaker-gateway.yml` | `libs/GatewayPlugins/BudgetBreakerGatewayPlugin` | Implemented |
| Payload Inspection Plugin | `openapi/v1/payload-inspection-gateway.yml` | `libs/GatewayPlugins/PayloadInspectionGatewayPlugin` | Implemented |
| Destructive Guardian Plugin | `openapi/v1/destructive-guardian-gateway.yml` | `libs/GatewayPlugins/DestructiveGuardianGatewayPlugin` | Implemented |
| Security Sentinel Plugin | `openapi/v1/security-sentinel-gateway.yml` | `libs/GatewayPlugins/SecuritySentinelGatewayPlugin` | Implemented |
| Role Health Check Plugin | `openapi/v1/role-health-check-gateway.yml` | — | Missing (spec only) |
| Tools Factory | `openapi/v1/tools-factory.yml` | `libs/ToolServer`, `apps/ToolsFactoryServer` | Implemented |
| Function Caller Service | `openapi/v1/function-caller.yml` | — | Missing (no target) |
| Persistence Service | `openapi/v1/persist.yml` | — | Missing (no target) |
| Planner Service | `openapi/v1/planner.yml`, `openapi/v0/planner.yml` | — | Missing (no target) |
| Baseline Awareness | `openapi/v1/baseline-awareness.yml` | — | Missing (no target) |
| DNS API | `openapi/v1/dns.yml` | `FountainCodex/DNS/*`, optional DNS runtime in gateway | Partial (DNS runtime present; HTTP API not wired) |
| Semantic Browser | `openapi/v1/semantic-browser.yml` | — | Missing (no target) |
| Typesense API (3rd‑party) | `openapi/typesense.yml` | — | Reference spec only |

---

## Root Agent Mission

Keep OpenAPI, code, and tests in lockstep; surface drift early; drive incremental, verifiable delivery of missing services and endpoints.

### Operating Procedure (Per Cycle)

1) Scan `openapi/*` and enumerate operationIds per spec.  
2) Map specs to Swift targets: plugins under `libs/GatewayPlugins/*`, services under `apps/*` or `libs/*`.  
3) Check handler stubs exist for every operationId; flag missing or mismatched routes.  
4) Implement or scaffold gaps (code + minimal tests).  
5) Run `swift build && swift test`; record outcomes.  
6) Update this manifest’s status snapshot and the backlog.

---

## Immediate Needs (Backlog, Prioritized)

1. Ship minimal Role Health Check Gateway plugin to satisfy `openapi/v1/role-health-check-gateway.yml` and register it in `apps/GatewayServer`.
2. Implement a skeleton Function Caller service matching `openapi/v1/function-caller.yml` (map operationIds to registered functions; start with in‑memory registry).
3. Stand up Persistence service scaffolding for `openapi/v1/persist.yml` (Typesense client stub or proxy decision; CRUD for corpora/baselines).
4. Add Planner service skeleton for `openapi/v1/planner.yml` (reason/execute with simple rule‑based placeholder).
5. Add Baseline Awareness stub service for streaming analytics per spec.
6. Wire DNS HTTP endpoints from `openapi/v1/dns.yml` to existing DNS runtime (zone CRUD + record list).
7. Audit LLM Gateway against v2 spec; fill missing endpoints and error handling.
8. Create a spec–route linter (script) to enforce opId→route/handler coverage in CI.

---

## Helpful Commands

- Build all: `swift build -v`
- Run gateway: `swift run gateway-server [--dns]`
- Run publishing frontend: `swift run publishing-frontend`
- Run tools factory: `swift run tools-factory-server`
- Run tests: `swift test -v`

---

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

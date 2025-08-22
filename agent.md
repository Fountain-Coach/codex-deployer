# 🧠 Repository + FountainAI Agent Manifest

**Last Updated:** August 22, 2025  
**Scope:** Full-repository self-improvement, orchestration, and MIDI-CI identity  
**Purpose:**  
1. Serve as a machine-actionable contract and coordination center for Codex-driven implementation, testing, and maintenance across all project modules.  
2. Publicly declare FountainAI’s identity as a **Swift 6 transparent reasoning engine** that speaks **MIDI 2.0 with Capability Inquiry (MIDI‑CI)** and projects its **OpenAPI specs** as the constitutional source of truth.  

---

## 🎹 FountainAI Identity (MIDI‑CI)

- **Manufacturer ID:** `TBD` (temporary `7D` for local dev; official MMA ID pending)  
- **Families / Models:**  
  - `Core.Kernel` — main reasoning engine  
  - `Core.Orchestrator` — ensemble orchestration  
  - `GUI.DefaultUI` — standard GUI  
  - `Service.*` — official FountainAI microservices (`Baseline`, `DriftDetector`, `ClientGen`, …)  
  - `Plugin.Author.PluginName` — delegated third‑party plugins under FountainAI’s umbrella  

Each endpoint replies to **Process Inquiry** with:  
`manufacturerId`, `family`, `model`, `version`, and a **persistent `muid`** (per‑install).  

### Projection of OpenAPI into MIDI‑CI Property Exchange
- `fountain.capabilities` — summary + OpenAPI `{version, sha256}`  
- `fountain.schema` — compact JSON Schema subset from OpenAPI components  
- `fountain.commands.schema` — list of invokable operations (IDs via `x-midi-ci-command-id`)  
- `fountain.commands` (SET) — invoke an operation by ID with validated input  
- `fountain.state` — small read model; progress, mode, corpus; may be **NOTIFY**  

### Transparent Reasoning Stream
- FountainAI emits reasoning via **incremental property notifications** (SSE‑like semantics over MIDI).  
- Consumers may display or audit this stream.  
- This is **observability**, not a programming API.  

**Claim:**  
> FountainAI is a **Swift 6 transparent reasoning engine** that participates in the **MIDI 2.0 ecosystem via MIDI‑CI**.  
> Its OpenAPI is the single constitutional source of truth, projected into MIDI‑CI.  
> It can stream its reasoning over MIDI. If you speak MIDI‑CI, you can discover it; if you speak OpenAPI, you already understand it.  

---

## 🎯 Mission
This agent maintains an up-to-date view of outstanding development tasks across the entire repository.  
It bridges declared intent (specs, interface plans) with verifiable implementation.  
Tasks are tracked in a structured **matrix** to allow vertical slice execution and repeatable progress.  

---

## 📋 Task Matrix

| Feature / Component | File(s) or Area | Action | Status | Blockers | Tags |
|---|---|---|---|---|---|
| OpenAPI loader | `Sources/FountainCodex/Parser/SpecLoader.swift` | Maintain JSON/YAML load + normalization | ✅ | — | parser |
| Spec validation | `Sources/FountainCodex/Parser/SpecValidator.swift` | Keep unique ids & params checks | ✅ | — | parser |
| Model emitter | `Sources/FountainCodex/ModelEmitter/*` | Generate Swift models from schemas | ✅ | — | generator |
| Client generator | `Sources/FountainCodex/ClientGenerator/*` | Emit type-safe requests & client | ✅ | — | generator, cli |
| Client errors | `Sources/FountainCodex/ClientGenerator/APIClient.swift` | Add non-200 error decoding | ✅ | — | client, generator |
| Server generator | `Sources/FountainCodex/ServerGenerator/*` | Emit router/types/handler **stubs** | ✅ | — | generator, server |
| DNS API handlers | `Sources/GatewayApp/GatewayServer.swift` | Keep CRUD for zones/records | ✅ | — | server, dns |
| Baseline analytics streaming | `Sources/FountainOps/Generated/Server/baseline-awareness/Handlers.swift` | Implement `streamHistoryAnalytics` handler | ✅ | — | server |
| DNS zone endpoints | `Sources/GatewayApp/GatewayServer.swift` | Add `createZone`, `deleteZone`, `listRecords` handlers | ✅ | — | server, dns |
| LLM Gateway | `openAPI/v2/llm-gateway.yml` | Implement `metrics_metrics_get`, `chatWithObjective` | ✅ | — | server, llm |
| Gateway Mgmt API | `openAPI/v1/gateway.yml` | Implement health/metrics/auth/cert/routes ops | ✅ | — | server |
| Planner (v1) | `openAPI/v1/planner.yml` | Implement planner ops (reason/execute/list/etc.) | ✅ | — | server, planner |
| Planner (v0) | `openAPI/v0/planner.yml` | Deprecate or alias to v1 | ✅ | — | docs, planner |
| Tools Factory | `openAPI/v1/tools-factory.yml` | Implement list/register ops | ✅ | — | server |
| Function Caller | `openAPI/v1/function-caller.yml` | Implement list/get/invoke/metrics | ✅ | — | server |
| Persistence API | `openAPI/v1/persist.yml` | Implement corpus/baseline/function/reflection ops | ✅ | — | server, storage |
| Typesense API | `openAPI/typesense.yml` | Decide proxy vs native subset | ✅ | — | server, design |
| Static site | `Sources/PublishingFrontend/*`, `Configuration/publishing.yml` | Serve docs/static; keep defaults | ✅ | — | server, docs |
| Gateway plugins | `LoggingPlugin`, `PublishingFrontendPlugin` | Keep logging & HTML fallback | ✅ | — | server |
| Resilience plugin | `BudgetBreakerPlugin` | Apply per-user budgets and circuit breakers | ✅ | — | server |
| DestructiveGuardianPlugin | `Sources/GatewayApp/DestructiveGuardianPlugin.swift` | Guard destructive ops w/ approval or tokens | ✅ | — | server, security |
| Certificate renewal | `Sources/GatewayApp/CertificateManager.swift` | Schedule/trigger renewal | ✅ | — | ops, tls |
| DNSSEC | `Sources/FountainCodex/DNSSECSigner.swift` | Integrate signer into engine | ✅ | — | security, dns |
| Metrics & logging | `GatewayServer`, `DNSMetrics` | Expose Prometheus-style metrics | ✅ | — | observability |
| Integration tests | `Tests/*` | E2E tests for generated servers | ✅ | — | test |
| DNS perf tests | `Tests/*` | UDP/TCP load & concurrency tests | ✅ | — | test, dns |
| SwiftLint in CI | `.swiftlint.yml`, `.github/workflows/*` | Add lint job to Actions | ✅ | — | ci, lint |
| Coverage in CI | `.github/workflows/*` | Publish coverage artifacts/badge | ✅ | — | ci, test |
| CI dependencies | `.github/workflows/ci.yml`, `sps/install-deps.sh` | Ensure coverage tools & SPS deps installed | ✅ | — | ci, sps |
| opId→handler audit | repo-wide | Script to diff specs vs code | ✅ | — | tooling, docs |
| Spec↔code drift | specs & servers | Track/close gaps per service | ✅ | — | process |
| SPS validation hooks | `sps/Sources/Validation/*`, `sps/Sources/SPSCLI/main.swift` | Add coverage + reserved-bit checks | ✅ | — | sps |
| SPS samples & usage docs | `sps/Samples`, `docs/sps-usage-guide.md` | Provide annotated sample PDFs and usage guide with page-range queries & validation hooks | ✅ | — | docs, sps |
| MIDI 2 library | `midi/*`, `sps/*`, `Sources/MIDI2/*` | Parse MIDI 2 spec via SPS and expose Swift Package module | ✅ | — | midi, sps, spm |
| Semantic browser & dissector | `sb/*` | Wire CLI commands and integrate Typesense indexer | ✅ | — | sb, cli, cdp, typesense, semantics |
| Toolsmith package | `FountainAIToolsmith/*` | Scaffold Toolsmith orchestration package with CLI | ✅ | — | toolsmith |
| LibPlist adapter tests | `Tests/FountainAIToolsmithTests/AdapterTests.swift` | Handle plutil help exit codes 0 or 1 | ✅ | — | toolsmith, test |
| SSE over MIDI demo | Package.swift, docs/sse-over-midi-guide.md, Examples/SSEOverMIDI | Add target, docs and demo | ✅ | — | midi, sse |

---

## 🧪 Execution Strategy

Each Codex execution cycle must:  
- Select tasks by tag or status  
- Implement code + tests + docs  
- Verify via `swift test` or CI  
- Update `Status` and `Blockers`  

---

## 🔁 Feedback Cycle

After each cycle:  
1. Update the matrix in-place  
2. Append structured result logs to `/logs/`  
3. Track recurring gaps in `/feedback/`  

---

## 📁 Placement

This file **lives at the repository root** as `agent.md`.  
It is the **canonical manifest** for both:  
- FountainAI’s **MIDI‑CI identity claim**  
- Codex‑driven **repository self‑improvement**  

---

## COPYRIGHT POLICY 🔐

**Mandatory Footer:**  
Every generated or updated file must end with:  

> © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

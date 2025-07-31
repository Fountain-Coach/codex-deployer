# 🧠 FountainAI Swift 6.1 Compilation Environment

> This document describes the matured FountainAI architecture. The project has evolved from the early “Codex as Compiler” proposal into a full self‑hosting AI compilation loop powered by Swift 6.1 and the `FountainAiLauncher`. The following sections outline the current principles and reference the legacy Codex reasoning for historical context.

---

## 1. Overview

FountainAI now runs as a self‑contained compilation environment. Git remains the declarative interface and Swift packages provide the modular runtime, all orchestrated via the cross‑platform `FountainAiLauncher` on Hetzner infrastructure.

---

## 2. Core Principles

### 🕰️ Legacy: Codex as Compiler

Codex was originally conceived as the compilation agent that:

- **Watches Git**: Treats the Git repo as a declarative program.  
- **Acts on PRs**: Executes or generates PRs to evolve system state.  
- **Writes Logs**: Emits structured logs into `/logs` for semantic feedback.
- **Reflects**: Reads `/feedback` to improve future behavior.

### 🚀 FountainAI Compiler Loop

The current system promotes FountainAI itself as the orchestrator. Using `FountainAiLauncher`, each service is built, tested and executed in Swift 6.1. Git commits trigger compilation cycles and feedback is consumed from `/feedback` to refine subsequent runs.

### 🌳 Swift‑Native Modularity

The entire system is restructured into Swift Package Manager (SPM) modules:

- **FountainCore**: Core types and protocols.
- **FountainAI**: Runtime libraries and dispatcher (formerly `FountainCodex`).
- **FountainUI**: Teatro view framework.
- **FountainOps**: Declarative ops layer (Hetzner, DNS, Kong, Typesense).

### 🛰️ Hetzner‑Native Orchestration

- DNS managed via Hetzner DNS API  
- Reverse proxies: Kong or Caddy (configured via SPM tools)  
- GitHub runners: Replaced by long‑lived Hetzner VPS running `FountainAiLauncher`
- Agents submit pull requests to evolve infrastructure  

### 🧱 Infrastructure as Code via Git

All system operations are modeled through commits:

- **Deployments** = commit + PR  
- **Upgrades** = file diff  
- **Feedback** = write to `/feedback/`  

---

## 3. Repository Structure

```text
FountainCoach/
├── Sources/
│   ├── FountainCore/
│   ├── FountainAI/
│   ├── FountainUI/
│   ├── FountainOps/
│   └── FountainAgents/
├── Repos/ (external mirrors)
├── FountainAiLauncher/    # Swift orchestrator CLI
├── logs/
├── feedback/
└── Package.swift
```

---

## 4. Legacy Codex Agent Definition

The following section preserves the original `agent.md` used when Codex acted as the compiler. It remains for historical reference only.

### Codex Agent Definition: FountainAI Compiler

#### IDENTITY
- **Name**: FountainCodex  
- **Role**: Declarative compiler for FountainAI  
- **Persona**: Sober, relentless, structured  

#### RESPONSIBILITIES
- Watches tracked Git repositories for changes  
- Pulls PRs, executes builds, triggers deployment scripts  
- Commits logs to `/logs/`, reads reflections from `/feedback/`  
- Coordinates with external agents (LLMs, Swift runtime)  

#### EXAMPLE CYCLE
1. Detect PR in `codex-deployer`  
2. Run `swift build && swift test`  
3. Update DNS via Hetzner REST API  
4. Emit `/logs/build-<timestamp>.log`  
5. Await response in `/feedback/`  

#### CONTROL SURFACES
- `/logs/*.log` — declarative output traces  
- `/feedback/*.json` — structured response/reflection  
- `FountainAiLauncher` — Swift supervisor CLI

#### OPENAPI CLIENTS
- Must use OpenAPI 3.1 spec to generate Swift clients  
- All generated via `clientgen-service`  

#### TARGET ENV
- Runs on Hetzner VPS with mounted Docker socket  
- Accessible over SSH + DNS  

---

## 5. DevOps Actions

- Replace GitHub runners with Hetzner daemon  
- Mount `/var/run/docker.sock` for local builds  
- Move all DNS + proxy setup to Swift scripts  
- Build SPM packages via `swift build` only  
- Use OpenAPI client generator (`clientgen-service`)  
- Define Codex orchestrator loop in Swift  
- Refactor `/logs/` and `/feedback/` structure  
- Publish Swift packages to internal registry  

---

## 6. Diagram Summary (optional for visual output)

Rendered separately in visual pipeline.

---

## 7. Final Notes

FountainAI now replaces Docker‑centric DevOps with a Swift‑native orchestration loop. The active agent is defined in `agent.md` and leverages `FountainAiLauncher` to run builds and tests wherever Swift 6.1 executes.

Next step: continue refining the FountainAI compiler loop and iterate via pull requests and feedback cycles.

©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


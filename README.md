# 🧠 FountainAI Codex + Swift Modularity Proposal

> This document outlines the proposed Codex‑driven, Swift‑native architecture for FountainAI, synthesizing all system layers into a single, declarative orchestration model. It defines Codex’s role as a compiler‑agent, the modular Swift package layout, Hetzner‑native DevOps orchestration, and embedded reasoning logic for infrastructure and AI evolution.

---

## 1. Overview

We propose a fully declarative, Git‑driven architecture for FountainAI where Codex acts as the compiler, Git repositories function as pub/sub interfaces, and the runtime stack is composed of modular Swift libraries and services, orchestrated through Hetzner‑native infrastructure.

---

## 2. Core Principles

### 🧠 Codex as Compiler

Codex is not just a Copilot—it is a compilation agent that:

- **Watches Git**: Treats the Git repo as a declarative program.  
- **Acts on PRs**: Executes or generates PRs to evolve system state.  
- **Writes Logs**: Emits structured logs into `/logs` for semantic feedback.  
- **Reflects**: Reads `/feedback` to improve future behavior.  

### 🌳 Swift‑Native Modularity

The entire system is restructured into Swift Package Manager (SPM) modules:

- **FountainCore**: Core types and protocols.  
- **FountainCodex**: Agent runtime + dispatcher.  
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
│   ├── FountainCodex/
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

## 4. Codex Agent Definition (Inline)

The following defines the `agent.md` for the Codex agent operating this system:

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

This proposal replaces Docker‑centric DevOps with a fully Swift‑native orchestration layer, defines Codex as a proper compiler interface over Git, and aligns all infrastructure agents as commit‑driven modules.

Next step: enact this system via a Codex PR and launch a full end‑to‑end reflection cycle.

©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


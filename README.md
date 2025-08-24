# 🌊 FountainAI

FountainAI is a **Swift 6 transparent reasoning engine** that speaks **MIDI 2.0 with Capability Inquiry (MIDI-CI)**.  
It projects its **OpenAPI specifications** as the constitutional source of truth and streams reasoning in **SSE-style updates over MIDI**.

**Claim:**  
> If you speak MIDI-CI, you can discover us.  
> If you speak OpenAPI, you already understand us.  

---

## 🚀 Quick start

Try streaming reasoning as Server-Sent Events over a local MIDI 2.0 loopback:

```bash
swift Examples/SSEOverMIDI/TwoSessions.swift
```

See [docs/sse-over-midi-guide.md](docs/sse-over-midi-guide.md) for setup details.

### Configure environment

Copy the example environment file and fill in your secrets:

```bash
cp .env.example .env
# edit .env and provide real values
```

`Scripts/boot.sh` and other utilities will automatically load variables from `.env`.

---

## 🎹 Identity

- **Manufacturer ID:** `TBD` (temporary `7D` in development; official MMA ID pending)  
- **Families / Models:**  
  - `Core.Kernel` — reasoning engine  
  - `Core.Orchestrator` — ensemble orchestration  
  - `GUI.DefaultUI` — standard GUI  
  - `Service.*` — official microservices  
  - `Plugin.Author.PluginName` — delegated community plugins  

Each endpoint replies to MIDI-CI **Process Inquiry** with `manufacturerId`, `family`, `model`, `version`, and persistent `muid`.

---

## 🖥️ Publishing Frontend

`Sources/PublishingFrontend` currently serves generated docs through a lightweight NIO HTTP server. The roadmap transforms it into the full user and administrator portal. It will render chat interfaces, plugin marketplaces, usage dashboards, and admin consoles for DNS, certificates, budgets, and system health, all driven by FountainAI's OpenAPI specifications. See [Sources/PublishingFrontend/README.md](Sources/PublishingFrontend/README.md) for requirements and future plans.

## 📚 Learn More

- [Architecture & Pillars](docs/architecture.md)  
- [Security](docs/security/README.md)  
- [Operations & Deployment](FountainAiLauncher/README.md)
- [Design Patterns](docs/design-patterns.md)  
- [Licensing Matrix](docs/licensing-matrix.md)  

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

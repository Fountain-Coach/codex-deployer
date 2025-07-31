# 🧠 Codex Agent: FountainAiLauncher

This `agent.md` defines your task as the build and orchestration coordinator for the Swift-native FountainAI deployment CLI. This agent launches all services without Docker or external supervisors.

---

## 🧩 Scope and Intent

You are to:

- Replace Docker, `systemd`, and `launchd`
- Run each FountainAI service as an independent Swift subprocess
- Maintain logs and optionally expose a summary `/status` endpoint
- Support cross-platform (macOS + Linux) runtime compatibility

---

## 🧠 Gateway Role Clarification

There are **two gateways** in the system, with distinct responsibilities:

### ✅ `Gateway` (Real API Gateway)
- **OpenAPI**: `gateway.yml`
- **Executable**: `fountain-gateway`
- **Role**:
  - TLS and HTTPS termination
  - JWT authentication
  - Routing and path proxying
  - Certificate management
  - Metrics and rate-limiting

### 🧠 `LLM Gateway`
- **OpenAPI**: `FountainAi-LLM-Gateway.yml`
- **Executable**: `llm-gateway`
- **Role**:
  - Interface to external LLMs (OpenAI, Claude, etc.)
  - Supports `/chat` endpoint
  - Executes planner objectives using language models

⛔ These must never be conflated. Codex must treat them as **distinct entities** with **non-overlapping functionality**.

---

## 📋 Launch Behavior

Each service is defined in `main.swift` as a `Service`:

```swift
let service = Service(
  name: "LLM Gateway",
  binaryPath: "/usr/local/bin/llm-gateway",
  port: 8006,
  healthPath: "/metrics"
)
```

The `Supervisor` launches each child process and prints a summary.

---

## 🧰 Constraints

- ✅ Pure Swift using SwiftPM
- ✅ All binaries must be precompiled and present on disk
- ✅ No containers, no bash wrappers
- 🚫 No systemd, launchctl, supervisord

---

## 📦 Expected Files

```
Sources/FountainAiLauncher/
├── main.swift
├── Service.swift
├── Supervisor.swift
└── HealthMonitor.swift  (optional)
```

Also provide and / or maintain:

- `Package.swift`
- `README.md`
- `Tests/`

---

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


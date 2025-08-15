# 🚀 FountainAiLauncher

The `FountainAiLauncher` is a **cross-platform Swift CLI** that launches, monitors, and coordinates the execution of all FountainAI microservices, including:

- the **LLM Gateway** for model orchestration
- the **FountainAI Gateway** for API routing, HTTPS, and access control
- and the entire OpenAPI-based FountainAI service mesh

This launcher replaces Docker, `systemd`, and `launchd` with a single, lightweight, Swift-native supervisor. It is suitable for both macOS and Linux deployments.

---

## 🎯 Features

- ✅ Cross-platform orchestration (macOS & Linux)
- 🌀 Launches all services as subprocesses
- 🔁 Optional auto-restart on failure
- 🌐 Optional `/status` and `/health` HTTP endpoint (coming soon)
- 📜 Logs directly to stdout or per-service log files
- 🔒 Requires no containers, no systemd, and no bash scripts

---

## 🧱 FountainAI Services Managed

| Service Name           | Executable Name        | Port  | Role Description |
|------------------------|------------------------|-------|------------------|
| Baseline Awareness     | `awareness-service`    | 8001  | Diff, drift, narrative patterns |
| Bootstrap Service      | `bootstrap-service`    | 8002  | Corpus and rules initializer |
| Planner Service        | `planner-service`      | 8003  | Delegates tasks and goals |
| Function Caller        | `function-caller`      | 8004  | Maps operationIds to HTTP |
| Persistence Service    | `persistence-service`  | 8005  | Typesense-backed corpus storage |
| **LLM Gateway**        | `llm-gateway`          | 8006  | Connects to external LLMs (OpenAI, Claude) |
| Semantic Browser       | `semantic-browser`     | 8007  | Headless browsing and semantic dissection |
| **Gateway**            | `fountain-gateway`     | 8010  | HTTPS, authentication, route proxying |
| Publishing Frontend    | `publishing-frontend`  | 8085  | Serves static publishing assets |
| Typesense Proxy        | `typesense-proxy`      | 8100  | Swift-native wrapper around Typesense |

---

## 📦 Project Layout

```
FountainAiLauncher/
├── Package.swift
├── agent.md                 ← Codex control file
├── README.md                ← This file
├── Sources/
│   └── FountainAiLauncher/
│       ├── main.swift
│       ├── Service.swift
│       ├── Supervisor.swift
│       └── HealthMonitor.swift  (optional)
└── Tests/
    └── FountainAiLauncherTests/
```

---

## 🔧 Required Service Binaries

The launcher expects the following executables to exist on disk. Install each service to the path shown or adjust `main.swift` if your binaries live elsewhere.

| Service Name         | Expected Path                             |
|----------------------|-------------------------------------------|
| Awareness Service    | `/usr/local/bin/awareness-service`        |
| Bootstrap Service    | `/usr/local/bin/bootstrap-service`        |
| Planner Service      | `/usr/local/bin/planner-service`          |
| Function Caller      | `/usr/local/bin/function-caller`          |
| Persistence Service  | `/usr/local/bin/persistence-service`      |
| LLM Gateway          | `/usr/local/bin/llm-gateway`              |
| Semantic Browser     | `/usr/local/bin/semantic-browser`         |
| Gateway              | `/usr/local/bin/fountain-gateway`         |
| Publishing Frontend  | `/usr/local/bin/publishing-frontend`      |
| Typesense Proxy      | `/usr/local/bin/typesense-proxy`          |

---

## 🛠️ Usage

```bash
swift build -c release
.build/release/FountainAiLauncher
```

Or install:

```bash
cp .build/release/FountainAiLauncher /usr/local/bin/fountainai-launcher
fountainai-launcher
```

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

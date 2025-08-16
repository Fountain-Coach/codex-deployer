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
- 📄 Loads service metadata from `services.json`
- 🔁 Optional auto-restart on failure
- 🌐 Optional `/status` and `/health` HTTP endpoint (coming soon)
- 📜 Logs directly to stdout or per-service log files
- 🔒 Requires no containers, no systemd, and no bash scripts

---

## 🧱 FountainAI Services Managed

| Service Name           | Executable Name        | Port  | Role Description |
|------------------------|------------------------|-------|------------------|
| Baseline Awareness     | `baseline-awareness`   | 8001  | Diff, drift, narrative patterns |
| Bootstrap              | `bootstrap`            | 8002  | Corpus and rules initializer |
| Planner                | `planner`              | 8003  | Delegates tasks and goals |
| Function Caller        | `function-caller`      | 8004  | Maps operationIds to HTTP |
| Persist                | `persist`              | 8005  | Typesense-backed corpus storage |
| **LLM Gateway**        | `llm-gateway`          | 8006  | Connects to external LLMs (OpenAI, Claude) |
| Semantic Browser       | `semantic-browser`     | 8007  | Headless browsing and semantic dissection |
| **Gateway**            | `fountain-gateway`     | 8010  | HTTPS, authentication, route proxying |
| Tools Factory          | `tools-factory`        | 8011  | Registers callable OpenAPI tools |
| Typesense              | `typesense`            | 8100  | Swift-native wrapper around Typesense |

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

## 🗂 Manual Service Registry

FountainAI does not include automatic service discovery. The launcher and the
`start-diagnostics.swift` script read from the manually curated
`Sources/FountainAiLauncher/services.json` file to know which FountainOps
servers to start. When a new service is added—or a path changes—you must update
this file yourself. Tools like `clientgen` can generate API clients, but they do
not register services in the launcher.

---

## 🔧 Required Service Binaries

The launcher expects the following executables to exist on disk. Install each service to the path shown or adjust `main.swift` if your binaries live elsewhere.

| Service Name         | Expected Path                             |
|----------------------|-------------------------------------------|
| Baseline Awareness   | `/usr/local/bin/baseline-awareness`       |
| Bootstrap            | `/usr/local/bin/bootstrap`                |
| Planner              | `/usr/local/bin/planner`                  |
| Function Caller      | `/usr/local/bin/function-caller`          |
| Persist              | `/usr/local/bin/persist`                  |
| LLM Gateway          | `/usr/local/bin/llm-gateway`              |
| Semantic Browser     | `/usr/local/bin/semantic-browser`         |
| Gateway              | `/usr/local/bin/fountain-gateway`         |
| Tools Factory        | `/usr/local/bin/tools-factory`            |
| Typesense            | `/usr/local/bin/typesense`                |

---

## 🩺 Diagnostics

Run the Swift diagnostics script before launching to verify all service binaries and required API keys are available:

```bash
swift Scripts/start-diagnostics.swift
```

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

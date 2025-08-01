
# 🌊 FountainAI

FountainAI is a self-hosting AI system built entirely in Swift 6.1. It compiles, tests and runs its services through the `FountainAiLauncher` without Docker or systemd. The previous architecture overview is archived in [`legacy/README.root-legacy.md`](legacy/README.root-legacy.md).

---

## Features

- **Swift 6.1 First** – all modules use the Swift Package Manager
- **Single Launcher** – `FountainAiLauncher` supervises every service
- **Feedback Loop** – commits produce build logs and await feedback in `/feedback`
- **Linux Native** – DNS and reverse proxy configuration managed via Swift scripts

---

## Repository Layout

```text
Sources/
├── FountainCore/
├── FountainAI/
├── FountainUI/
├── FountainOps/
├── FountainAgents/
FountainAiLauncher/
logs/
feedback/
Package.swift
```

---

## Quick Start


```bash
swift build -c release
swift test
.build/release/FountainAiLauncher
```

## System Architecture

FountainAI is a collection of Swift packages orchestrated by the `FountainAiLauncher` CLI. Each module provides a specific layer of the stack, from HTTP routing to DNS management.

![image_gen: Overview diagram with modules FountainAiLauncher, GatewayApp, PublishingFrontend, FountainCodex and FountainOps connected by arrows]

### Core Modules

#### FountainAiLauncher
This executable supervises all running services. It defines a `Service` model and a `Supervisor` that launches and terminates processes. The main entry point lists each service binary to run. Key code is found in [`FountainAiLauncher/Sources/FountainAiLauncher/Supervisor.swift`](FountainAiLauncher/Sources/FountainAiLauncher/Supervisor.swift) and [`main.swift`](FountainAiLauncher/Sources/FountainAiLauncher/main.swift).

#### GatewayApp
A lightweight HTTP gateway built on SwiftNIO. The server composes a list of plugins conforming to [`GatewayPlugin`](Sources/GatewayApp/GatewayPlugin.swift). Plugins such as [`LoggingPlugin`](Sources/GatewayApp/LoggingPlugin.swift) and [`PublishingFrontendPlugin`](Sources/GatewayApp/PublishingFrontendPlugin.swift) modify requests and responses before or after routing. The server implementation resides in [`GatewayServer.swift`](Sources/GatewayApp/GatewayServer.swift).

![image_gen: Plugin based HTTP gateway with request flow through prepare, router, respond]

#### PublishingFrontend
A simple static file server used to host generated documentation or assets. Configuration is loaded from [`Configuration/publishing.yml`](Configuration/publishing.yml). The core logic is defined in [`PublishingFrontend.swift`](Sources/PublishingFrontend/PublishingFrontend.swift) and exposes a small HTTP kernel for serving files.

#### FountainCodex
Libraries for parsing OpenAPI specifications and generating Swift clients and servers. The [ClientGenerator](Sources/FountainCodex/ClientGenerator/ClientGenerator.swift) emits type-safe API requests and a reusable `APIClient`. Supporting infrastructure such as [`HTTPKernel`](Sources/FountainCodex/IntegrationRuntime/HTTPKernel.swift) powers both GatewayApp and the publishing server.

#### FountainOps
Operational assets like Dockerfiles and OpenAPI specifications live under [`Sources/FountainOps`](Sources/FountainOps). The `openAPI` folder lists all service specs used for client generation.

![image_gen: Flow from OpenAPI specs to generated clients and server binaries]

### Design Patterns
The project adopts several common patterns which can be seen in the implementation files:

- **Client/Server Pattern** – `HTTPKernel` in [`IntegrationRuntime`](Sources/FountainCodex/IntegrationRuntime/HTTPKernel.swift) enables a simple server abstraction used by the gateway and publishing frontend.
- **Plugin Pattern** – `GatewayPlugin` and its implementations ([`LoggingPlugin`](Sources/GatewayApp/LoggingPlugin.swift), [`PublishingFrontendPlugin`](Sources/GatewayApp/PublishingFrontendPlugin.swift)) allow cross-cutting behavior around request handling.
- **Supervisor Pattern** – `Supervisor` in [`FountainAiLauncher`](FountainAiLauncher/Sources/FountainAiLauncher/Supervisor.swift) manages multiple child processes to keep services alive.
- **Declarative Configuration** – YAML files in [`Configuration`](Configuration) provide runtime settings such as gateway certificates and server ports, loaded at startup by the publishing frontend.

![image_gen: Sequence of FountainAiLauncher starting services which communicate through the gateway]

For further discussion of these patterns, see [docs/design_patterns.md](docs/design_patterns.md) and related planning documents throughout the repository.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


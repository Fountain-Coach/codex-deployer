# 🧩 Design Patterns

FountainAI combines code generation, plugin-based orchestration, and MIDI‑native streaming to form a transparent reasoning platform.
This document outlines the core design patterns that recur across the codebase and links to representative implementations.

## Constitutional Code Generation

OpenAPI specifications act as the **single source of truth**.  The pipeline loads specs, validates them, and emits models, clients, and server stubs.
- [SpecLoader](../Sources/FountainCodex/Parser/SpecLoader.swift) – reads JSON/YAML and normalizes the result.
- [ModelEmitter](../Sources/FountainCodex/ModelEmitter) – turns schemas into Swift types.
- [ClientGenerator](../Sources/FountainCodex/ClientGenerator) – builds strongly typed HTTP clients.
- [ServerGenerator](../Sources/FountainCodex/ServerGenerator) – scaffolds routing and handler stubs.

## Gateway Middleware Chain

Incoming HTTP requests traverse a configurable plugin stack before reaching generated routes.
- [GatewayPlugin](../Sources/GatewayApp/GatewayPlugin.swift) defines `prepare`/`respond` hooks.
- [GatewayServer](../Sources/GatewayApp/GatewayServer.swift) composes plugins and exposes health/metrics endpoints.
- Example plugins: [LoggingPlugin](../Sources/GatewayApp/LoggingPlugin.swift), [BudgetBreakerPlugin](../Sources/GatewayApp/BudgetBreakerPlugin.swift).

## Transparent Reasoning Stream

Thoughts and progress updates stream as Server‑Sent Events over MIDI 2.0.
- [SSEOverMIDI library](../Sources/SSEOverMIDI) abstracts senders and receivers.
- [TwoSessions example](../Examples/SSEOverMIDI/TwoSessions.swift) demonstrates bi‑directional communication.
- [SSE over MIDI guide](sse-over-midi-guide.md) explains setup.

## Service Orchestration

A lightweight launcher supervises micro‑services declared in configuration.
- [FountainAiLauncher](../FountainAiLauncher/README.md) details the supervisor.
- Configuration files live in [`Configuration/`](../Configuration).

## Toolsmith & Dynamic Tooling

Tooling can be generated on demand from OpenAPI descriptions.
- [FountainAIToolsmith](../FountainAIToolsmith) scaffolds tool runtimes and CLI wrappers.
- The [toolsmith orchestration guide](toolsmith-orchestration.md) shows end‑to‑end flows.

## Publishing Frontend

Documentation and static assets are served by a minimal HTTP frontend.
- [PublishingFrontend](../Sources/PublishingFrontend) renders markdown and serves the `/docs` tree.
- [Architecture overview](architecture.md) gives context for how the frontend fits into the system.

## Security & Observability

Security measures and telemetry share a consistent plugin‑driven style.
- [DestructiveGuardianPlugin](../Sources/GatewayApp/DestructiveGuardianPlugin.swift) enforces approval for sensitive operations.
- [Gateway metrics](../Sources/GatewayApp/GatewayServer.swift#L26-L39) expose Prometheus‑style counters.
- Further guidance is in the [security docs](security/README.md).

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

# 🌊 FountainAI

FountainAI assembles a family of Swift services that work together to run a secure, observable and extensible AI platform. Rather than centering on a single CLI, the repository balances gateways, operations tooling and code generation as equal pillars of the ecosystem.

## Architecture Pillars

- **GatewayApp** – Plugin-driven HTTP and DNS gateway built on SwiftNIO. It composes `GatewayPlugin` implementations such as `LoggingPlugin` and `PublishingFrontendPlugin` to handle cross-cutting concerns.
- **FountainOps** – Operational assets including Dockerfiles, OpenAPI specifications and generated client/server code used for deployment and monitoring.
- **FountainCodex** – Libraries for loading OpenAPI specs and emitting Swift clients and servers, powering both gateway and publishing services.
- **PublishingFrontend** – Static file host for generated documentation and artifacts, configured through YAML in `Configuration/`.
- **FountainAiLauncher** – A minimal supervisor binary that starts and watches other services; it is an entrypoint, not the core architecture.

## Security Architecture

The `SECURITY` directory documents threats such as unauthorized access, destructive API calls, prompt injection, denial of service and supply-chain attacks. Recommended mitigations include OAuth2-based access control, scoped permissions, rate limiting, input filtering, anomaly monitoring, and signed container images. See [SECURITY/README.md](SECURITY/README.md) for comprehensive guidance.

## Operations and Deployment

FountainOps connects specifications in `openAPI/` with generated code and container images. The gateway exposes Prometheus-style metrics, handles TLS certificate renewal and integrates DNS management for end-to-end service delivery.

## Design Patterns

- **Plugin Pattern** – `GatewayPlugin` implementations provide extensibility around request handling.
- **Declarative Configuration** – YAML files in `Configuration/` supply runtime settings for gateways and publishing services.
- **Supervisor Pattern** – `FountainAiLauncher` monitors child processes to keep services running.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

# GatewayApp

Comprehensive implementation documentation for the FountainAI Gateway. The gateway is a lightweight SwiftNIO-based HTTP server that composes middleware plugins and exposes management endpoints for health, metrics, certificate renewal and dynamic routing.

## OpenAPI Specification
The Gateway API is described by the [OpenAPI document](../FountainOps/FountainAi/openAPI/v1/gateway.yml). Key operations include:

- `GET /health` – uptime check returning an empty JSON object.
- `GET /metrics` – runtime counters and gauges encoded as JSON, secured with bearer authentication.
- `POST /auth/token` – verifies client credentials and issues short-lived JWTs.
- `GET /certificates` – reads metadata about the active TLS certificate.
- `POST /certificates/renew` – triggers the certificate renewal script.
- `GET /routes` – lists configured reverse-proxy routes.
- `POST /routes` – persists a new reverse-proxy route.
- `PUT /routes/{routeId}` – updates an existing route definition.
- `DELETE /routes/{routeId}` – removes a configured route.

Refer to the OpenAPI file for request and response schemas, authentication requirements and error models.

## Implementation

### `GatewayServer`
[`GatewayServer.swift`](GatewayServer.swift) wires the SwiftNIO HTTP kernel, executes the plugin pipeline and implements the management endpoints listed above. It also persists dynamic routes and delegates DNS operations when a `ZoneManager` is provided.

### `CertificateManager`
[`CertificateManager.swift`](CertificateManager.swift) schedules execution of a renewal script and exposes `start`, `stop` and `triggerNow` for manual control.

### `CredentialStore`
[`CredentialStore.swift`](CredentialStore.swift) loads API client credentials from environment variables, validates pairs and signs or verifies JSON Web Tokens used by `AuthPlugin`.

### Entry Point
[`main.swift`](main.swift) constructs a `GatewayServer` with `LoggingPlugin` and `PublishingFrontendPlugin` and starts listening on port 8080. Passing `--dns` additionally launches a DNS server backed by `ZoneManager`. See [DNS subsystem docs](../FountainCodex/DNS/README.md) for zone management and server details.

## Plugin Index

| Plugin | Description | Docs |
| --- | --- | --- |
| [GatewayPlugin](GatewayPlugin.swift) | Protocol defining `prepare` and `respond` hooks for request/response middleware. | [documentation](../../docs/README.md#gatewayplugin) |
| [AuthPlugin](AuthPlugin.swift) | Enforces bearer-token authentication on protected paths. | [documentation](../../docs/README.md#authplugin) |
| [LoggingPlugin](LoggingPlugin.swift) | Logs every request and response for debugging. | [documentation](../../docs/README.md#loggingplugin) |
| [PublishingFrontendPlugin](PublishingFrontendPlugin.swift) | Serves static files when the router returns `404`. | [documentation](../../docs/README.md#publishingfrontendplugin) |

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

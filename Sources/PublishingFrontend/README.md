# Publishing Frontend

The Publishing Frontend is a lightweight NIO-based HTTP server used today to host generated documentation and other static assets. It acts as a placeholder for the future human interface to FountainAI.

## Status Quo

- `PublishingFrontend.swift` starts an HTTP server on the configured port and serves files from `./Public`.
- `APIClient.swift`, `APIRequest.swift`, and `DNSProvider.swift` provide minimal primitives for interacting with HTTP APIs and DNS providers.
- Configuration lives in `Configuration/publishing.yml` with defaults for port and document root.

## Vision

The module will evolve into the comprehensive user and administrator portal for the FountainAI platform. Its responsibilities expand from static hosting to:

- Rendering a full single-page or server-side Swift web application.
- Presenting chat interfaces, tool discovery, and usage dashboards for end users.
- Delivering administrative consoles for DNS, certificates, budgets, plugins, and analytics.
- Streaming transparent reasoning and notifications via SSE or MIDI-compatible transports.
- Integrating tightly with FountainAI's OpenAPI specifications so that every interaction is typed, discoverable, and automatable.

## Roles & Expectations

### General Users

- Browse public documentation and marketing pages.
- Chat with the reasoning engine and install plugins.
- Track usage, cost, and personal budgets.

### Administrators

- Manage user accounts, authentication, and roles.
- Approve or revoke plugins and monitor gateway activity.
- Configure DNS records and TLS certificates for custom domains.
- Inspect system health, logs, and metrics.
- Trigger dataset refreshes or model re-training cycles.

## Requirements Outline

**Functional**

- Serve a responsive SPA/SSR application.
- Authenticate via OAuth or token-based flows.
- Consume OpenAPI specs to generate clients and forms.
- Offer dashboards for users and admins.
- Expose SSE endpoints for live reasoning streams.

**Non-Functional**

- Accessible and localized UI.
- Auditable operations with traceable actions.
- Extensible plugin architecture for community modules.

## OpenAPI Integration

The frontend itself exposes its capabilities through an OpenAPI description. Client code and administrative tooling are generated from this spec, making the UI a thin layer over the canonical API contract. External automation can reuse the same OpenAPI surface.

## Business Value

- Provides a unified entry point to FountainAI, reducing onboarding friction.
- Lowers operational costs by centralizing administration.
- Encourages ecosystem growth by making plugins discoverable and manageable.

## Running Today

```bash
swift run PublishingFrontend
```

Override defaults in `Configuration/publishing.yml` to change the port or document root.

## Roadmap

1. Replace static serving with a modular web app framework.
2. Implement authentication and session management.
3. Bind admin controls to gateway and tool APIs.
4. Publish an OpenAPI spec for the frontend endpoints.
5. Integrate plugin marketplace and budget monitoring.
6. Add theming and branding facilities.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

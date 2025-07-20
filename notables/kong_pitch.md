# Kong Pitch

The repository treats **`kong-codex`** as one of the core managed repositories. Its purpose is to host gateway configuration and plugin definitions under `/srv/deploy/repos/kong-codex/`.

By choosing Kong as our API gateway, we benefit from the following features without building them from scratch:

1. **Routing and Load Balancing** – Directs requests to the correct backend and balances traffic across healthy targets.
2. **Authentication and Authorization** – Supports key-based auth, OAuth 2.0, JWT validation, and more, with plugins that can be combined for layered security.
3. **Rate Limiting and Quotas** – Protects services from abuse with per-API or per-consumer rate limiting, using sliding or fixed window policies.
4. **Logging and Analytics** – Logs requests to external systems and integrates with metrics tools like Datadog or Prometheus.
5. **Request and Response Transformation** – Modifies headers or payloads to fit service requirements.
6. **Caching** – Offers response caching with TTL-based invalidation.
7. **Extensibility via Plugins** – Custom plugins can be written in Lua or other languages using the plugin server framework.
8. **Service Discovery and Declarative Config** – Works with dynamic Admin API updates or YAML/JSON configuration files.
9. **Protocol Support** – Handles HTTP/HTTPS, gRPC, WebSockets, and can act as an ingress controller for Kubernetes.

Configuration variables for the deployment system are documented in [`docs/environment_variables.md`](../docs/environment_variables.md). Although no Kong-specific variables are listed there, we can introduce them in the future and keep that file updated.

Overall, Kong provides production-ready routing, security, observability, and extensibility, reducing the need for a custom gateway built in Swift or Python.


````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````


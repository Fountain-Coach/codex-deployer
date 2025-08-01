# Swift API Gateway Proposal

We plan to build an API gateway entirely in Swift to replace Kong. The goal is to keep our stack consistent and to leverage our existing OpenAPI-driven workflow.

## Motivation
- **Single Language Stack**: All services, clients, and the gateway will be written in Swift. This aligns with our generated client/server code in `Sources/FountainOps`.
- **OpenAPI First**: The gateway itself will expose an OpenAPI spec under version control, similar to `Sources/FountainOps/FountainAi/openAPI/README.md`.
- **Full Ownership**: By avoiding Lua plugins or external gateways, we maintain complete oversight and quality assurance.

## Features
1. **Automatic Let's Encrypt Certificate Management**
   - Retrieve and renew TLS certificates via Let's Encrypt so the gateway serves HTTPS by default.
2. **Routing and Load Balancing**
   - Route requests based on path and version to the appropriate backend service. Equivalent to Kong's routing but implemented with SwiftNIO.
3. **Authentication**
   - Provide token-based authentication, verifying credentials before forwarding requests. Additional policies can be described in the OpenAPI security section.
4. **Rate Limiting**
   - Basic request quota tracking with in-memory or Redis counters to protect services.
5. **Logging and Metrics**
   - Integrate with our existing log aggregation setup (`docs/log_aggregation.md`). Expose Prometheus metrics on `/metrics` just like the LLM Gateway.
6. **Request Transformation**
   - Allow lightweight header manipulation or JSON body validation directly in Swift.
7. **Typesense Persistence**
  - Use Typesense as the primary persistence layer. The cluster is defined by
    our `repos/fountainai/Sources/FountainOps/FountainAi/openAPI/typesense.yml` spec and accessed via
     a Swift client generated through `clientgen-service`. Request metadata,
     tokens and logs are stored as Typesense documents for fast retrieval.

## Implementation Outline
- **Spec Definition**: Author an OpenAPI spec in `FountainAi/openAPI/v1/gateway.yml`. This defines endpoints for the gateway itself, such as health checks and metrics.
- **Code Generation**: Use the existing `clientgen-service` to produce Swift servers and clients, following the process in `Sources/FountainOps/regenerate.sh`.
- **Service Module**: Add a new SPM target `gateway-server` that compiles the generated server handlers.
- **Certificate Management**: Automate HTTPS with Let's Encrypt using an ACME client and renewal timer.
- **Configuration**: Read routing tables and rate limits from a YAML or JSON file stored in the repository. Updates can be rolled out declaratively via commits.
- **Typesense Client Integration**: Generate a Swift client from the Typesense
  OpenAPI specification and embed it into the `gateway-server` target for
  persistence operations.

## Next Steps
1. Draft the gateway OpenAPI specification with minimal routes.
2. Extend `docker-compose.yml` to include the new service built from `Generated/Server/gateway`.
3. Review existing docs on Kong (`docs/notes/kong_pitch.md`) to match feature parity where necessary.
4. Run `clientgen-service` against the Typesense OpenAPI spec to generate
   the persistence client and commit the resulting code.
5. Automate certificate issuance and renewal so HTTPS works out of the box.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

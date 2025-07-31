# Docker Deprecation Strategy for FountainAI Deployment

The Codex deployer currently relies on Docker images and `docker compose` files to start the Gateway, FountainAI services, and the Typesense server. Moving toward a Swift‑native tooling chain allows us to simplify the runtime environment and remove Docker as a hard dependency. The local `typesense-server` built from the OpenAPI spec can act as a **proxy** so the actual Typesense cluster may run anywhere—locally, remotely, or in a distributed setup.

## Goals
- Ship all services as prebuilt Swift binaries or SPM packages.
- Use `systemd` units on Linux to manage the processes.
- Provide Xcode schemes or launchd plists for macOS and other Apple platforms.
- Keep the workflow consistent with the existing environment variable setup.

## Migration Steps
1. **Build Binaries** – Compile each service (`gateway-server`, `planner-server`, `typesense-server`, etc.) with `swift build -c release`. Archive the resulting executables for direct distribution.
2. **Replace Compose Files** – Translate each service definition from `docker-compose.yml` into individual `systemd` service files. The sample `fountain-dispatcher.service` under `systemd/` can serve as a template.
3. **Proxy Typesense** – Run the `typesense-server` binary as a lightweight proxy. Configure it with `TYPESENSE_URL` and `TYPESENSE_API_KEY` so it can forward requests to a Typesense cluster running locally or remotely. Provide optional helper scripts for launching a standalone Typesense instance if developers need a full stack on one machine.
4. **Update Documentation** – Revise the macOS guides (`mac_local_testing.md` and `mac_docker_tutorial.md`) to show local builds and systemd or launchd setup instead of Docker containers.
5. **CI Adjustments** – Remove the Docker build step in `dispatcher.env` (`DISPATCHER_BUILD_DOCKER`) once all services have direct build instructions.

By gradually phasing out container usage we reduce startup time and simplify production deployments across Linux and macOS. The existing OpenAPI‑driven code generation remains unchanged.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

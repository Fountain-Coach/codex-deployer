# Future Priorities

The status reports show that all FountainAI services are generated but remain largely skeletal:
- Servers compile and print startup messages but lack an HTTP runtime.
- Clients decode responses as raw `Data` and models are untyped.
- No persistence layer or external integrations are wired up.
- Unit tests exercise only the generator, not service behavior.

To progress toward a functional release we should:

1. **Implement typed models** – expand the parser and generators so requests and responses use concrete Swift types shared by clients and servers.
2. **Add a minimal HTTP runtime** – integrate a SwiftNIO-based listener so each generated server can process requests concurrently.
3. **Connect external dependencies** – wire the Persistence service to Typesense and hook the Planner and Function Caller into the LLM Gateway.
4. **Introduce integration tests** – use the generated SDKs to call the running servers and verify end‑to‑end flows.
5. **Automate CI and container builds** – run `swift build` and `swift test` on every pull request and document Docker workflows for deployment.
6. **Update the execution plan** – reconcile `Docs/Historical/codex-plan.md` with completed work and these new tasks.

```` text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

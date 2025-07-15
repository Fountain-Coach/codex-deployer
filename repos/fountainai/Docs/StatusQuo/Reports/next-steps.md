# Next Steps Toward Stable Production Release

The services now share a minimal Swift networking runtime and typed request/response models. Basic integration tests run across all microservices using this runtime. Persistence connects to a real Typesense instance and the LLM Gateway forwards requests to OpenAI.

To move the project toward a stable production release:

1. **Connect services to real infrastructure** – ✅ Persistence now talks to a running Typesense instance and the LLM Gateway proxies to OpenAI.
2. **Expand service logic** – complete the Function Caller and Planner implementations so workflows execute end‑to‑end.
3. **Persist tool definitions** – ✅ Tools Factory stores OpenAPI documents and exposes registration APIs.
4. **Add authentication** – ✅ All services enforce bearer tokens and validate inputs.
5. **Harden testing** – grow the integration tests to cover more scenarios and enable CI metrics. ✅ Invocation success and failure counters are now recorded by the Function Caller service.
6. **Finalize deployment assets** – refine the Docker images, document environment variables, and provide examples for Kubernetes.
   See [environment_variables.md](../../../../../docs/environment_variables.md) for the latest list.

Following these steps will transition the FountainAI suite from generated stubs to fully functional, deployable microservices.

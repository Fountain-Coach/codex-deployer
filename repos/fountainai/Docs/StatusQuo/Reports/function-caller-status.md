# Function Caller Service – Implementation Status

## Overview
The Function Caller maps OpenAI function-calling plans to HTTP operations using definitions from the Tools Factory.
Spec path: `FountainAi/openAPI/v1/function-caller.yml` (version 1.0.0).

## Implementation State
- OpenAPI operations defined: 3
- Generated client SDK at `Generated/Client/function-caller`
- Generated server kernel at `Generated/Server/function-caller`
- Handlers dispatch registered functions via ``FunctionDispatcher`` using ``TypesenseClient``
- Client decodes typed models for all endpoints
- When `TYPESENSE_URL` is set the dispatcher looks up functions from the external Typesense service
- See [environment_variables.md](../../../../../../docs/environment_variables.md) for required configuration.
- Authentication middleware checks the `FUNCTION_CALLER_AUTH_TOKEN` environment variable
- Integration tests verify the `list_functions` endpoint and invocation flows
- Tools Factory integration allows dynamic registration via `/tools/register`
- Dispatcher reports errors with structured JSON responses
- Prometheus metrics available at `/metrics`
- Invocation parameters validated against stored JSON Schemas

## Next Steps toward Production
- Add structured logging and per-endpoint metrics
- Provide a Docker Compose example wiring the Tools Factory and Function Caller
- Implement persistent caching of function definitions

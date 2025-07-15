# Tools Factory Service – Implementation Status

## Overview
The Tools Factory registers and manages tool definitions consumed by the Function Caller.
Spec path: `FountainAi/openAPI/v1/tools-factory.yml` (version 1.0.0).

## Implementation State
- OpenAPI operations defined: 2
- Generated client SDK at `Generated/Client/tools-factory`
- Generated server kernel at `Generated/Server/tools-factory`
- Server persists tools via `TypesenseClient`
- Client decodes typed models
- When `TYPESENSE_URL` is configured the service will persist tool definitions remotely
- See [environment_variables.md](../../../../../../docs/environment_variables.md) for configuration options
- Integration tests cover registration and listing flows
- Authentication middleware checks the `TOOLS_FACTORY_AUTH_TOKEN` environment variable

### Example Usage

```bash
curl -X POST \
     -H "Content-Type: application/x-yaml" \
     --data-binary @function-caller.yml \
     http://tools-factory.fountain.coach/api/v1/tools/register

curl http://tools-factory.fountain.coach/api/v1/tools
```

Invalid documents return `400` with an `ErrorResponse`.

## Next Steps toward Production
- Harden validation rules and error reporting
- Add persistence migrations for production databases

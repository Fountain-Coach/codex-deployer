# Typesense Server Full API Implementation Plan

This plan details how to implement every endpoint defined in `repos/typesense-codex/openapi/openapi.yml` so the generated `typesense-server` can act as a complete proxy to a real Typesense cluster.

## 1. Regenerate Code from OpenAPI

1. Update `clientgen-service` to read the Typesense spec and emit Swift server stubs for all operations.
2. Run `clientgen-service` and commit the generated code under `Sources/FountainOps/Generated/Server/typesense`.

## 2. Extend `TypesenseService`

1. For each `operationId` in the spec, create an async method that performs the HTTP call using `APIClient`.
2. Preserve the existing helper methods (`listCollections`, `createCollection`, `search`) and follow the same structure for new ones.
3. Support environment configuration through `TYPESENSE_URL` and `TYPESENSE_API_KEY` so tests and other services can point to a local cluster.

## 3. Implement Server Handlers

1. Use the generated router to map each path and HTTP method to a function in `Handlers.swift`.
2. Call the corresponding method on `TypesenseService` and return the JSON payload with appropriate HTTP status codes.
3. Remove the `501` placeholders once a route is implemented. All endpoints should return the real Typesense responses.

## 4. Provide Unit Tests

1. Add tests in `Tests/TypesenseServerTests` that start the server on a random port and exercise each endpoint.
2. Use a lightweight mock or the official Typesense Docker container for test data.
3. Ensure `swift test` passes on Linux and macOS.

## 5. Deployment Considerations

1. Update the Dockerfile under `Sources/FountainOps/Generated/Server/typesense` to build the new server binary.
2. Document required environment variables in `docs/environment_variables.md`.
3. Integrate the server into the `docker-compose.yml` used by other FountainAI services.

Following this plan will turn the current stub into a full-fledged Typesense proxy in Swift.

### Progress

The server currently supports the following endpoints (commit):

- `GET /collections` – `55922a5`
- `POST /collections` – `55922a5`
- `GET /collections/{collectionName}` – `9d2ad4f`
- `DELETE /collections/{collectionName}` – `792ff5b`
- `GET /collections/{collectionName}/documents/search` – `55922a5`
- `GET /keys` – `792ff5b`
- `POST /keys` – `792ff5b`
- `GET /keys/{keyId}` – `e6801c5`
- `DELETE /keys/{keyId}` – `9f4ad19`
- `GET /aliases` – `384dc86`
- `PUT /aliases/{aliasName}` – `1bce1dc`
- `GET /aliases/{aliasName}` – `ca44a96`
- `DELETE /aliases/{aliasName}` – `ebe309a`
- `GET /debug` – `4de0ad4`
- `GET /health` – `ce544f8`
- `GET /operations/schema_changes` – `76d8956`
- `GET /collections/{collectionName}/synonyms/{synonymId}` – `5c2fb5d`
- `GET /collections/{collectionName}/documents/export` – `2905227`
- `POST /collections/{collectionName}/documents/import` – `11a3a92`
- `GET /collections/{collectionName}/documents/{documentId}` – `637dca5`
- `DELETE /collections/{collectionName}/documents/{documentId}` – `9a12fff`
- `GET /conversations/models` – `fefbea0`
- `POST /conversations/models` – `f66f5f3`
- `GET /conversations/models/{modelId}` – `361d89c`
- `PUT /conversations/models/{modelId}` – `a1a5fea`
- `DELETE /conversations/models/{modelId}` – `285ca93`

Last updated at `9f4ad19`.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

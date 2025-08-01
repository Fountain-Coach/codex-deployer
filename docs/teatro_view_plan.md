# TeatroView Feature Project

TeatroView provides a graphical interface for Typesense using the Teatro view engine. It consumes the comprehensive OpenAPI specification shipped under `repos/fountainai/Sources/FountainOps/FountainAi/openAPI/typesense.yml`.

## Objectives

- Generate a Swift client from the OpenAPI file to access collections and search APIs.
- Expose Teatro-based views for browsing collections, searching documents, and editing schemas.
- Bootstrap default schemas by reusing `repos/seeding/scripts/bootstrap_typesense.py`.
- Package the app as an open-source project under `repos/TeatroView` so contributors can build and run it on macOS.

## Roadmap

1. **Client Generation** – automate Swift client generation from the OpenAPI spec.
2. **Data Layer** – read `TYPESENSE_URL` and `TYPESENSE_API_KEY` to configure API calls.
3. **Teatro Views** – implement collection browser, search UI, and schema editor.
4. **SwiftUI Shell** – embed Teatro scenes in a minimal SwiftUI app.
5. **Documentation** – keep `README.md` and this plan updated as features land.

## Integration Steps

The [LLM-First Typesense GUI](llm_first_typesense_gui.md) outlines a chat-centric workflow that complements the existing TeatroView plan. Follow these concrete steps to integrate it with the Codex deployer:

1. **Regenerate the client** – run `scripts/generate_typesense_client.sh` whenever `openapi.yml` changes so TeatroView uses the latest Typesense API.
2. **Add the Chat Workspace** – build a SwiftUI view that forwards prompts to the LLM and streams answers, then expose `typesense.search` tool calls.
3. **Implement the Retrieval Inspector** – show Typesense hits, scores, and raw JSON next to the chat for full transparency.
4. **Expose corpus management** – provide a schema browser and quick actions (clone, toggle embeddings) using Teatro components.
5. **Tie into the build loop** – configure the dispatcher to rebuild and restart TeatroView automatically when sources change.

See [environment_variables.md](environment_variables.md) for required variables such as `TYPESENSE_URL` and `TYPESENSE_API_KEY`.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

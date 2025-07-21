# TeatroView Feature Project

TeatroView provides a graphical interface for Typesense using the Teatro view engine. It consumes the comprehensive OpenAPI specification shipped under `repos/typesense-codex/openapi/openapi.yml`.

## Objectives

- Generate a Swift client from the OpenAPI file to access collections and search APIs.
- Expose Teatro-based views for browsing collections, searching documents, and editing schemas.
- Bootstrap default schemas by reusing `repos/typesense-codex/scripts/bootstrap_typesense.py`.
- Package the app as an open-source project under `repos/TeatroView` so contributors can build and run it on macOS.

## Roadmap

1. **Client Generation** – automate Swift client generation from the OpenAPI spec.
2. **Data Layer** – read `TYPESENSE_URL` and `TYPESENSE_API_KEY` to configure API calls.
3. **Teatro Views** – implement collection browser, search UI, and schema editor.
4. **SwiftUI Shell** – embed Teatro scenes in a minimal SwiftUI app.
5. **Documentation** – keep `README.md` and this plan updated as features land.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

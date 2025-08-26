# OpenAPI Directory Conventions

1. **Versioned specs**  
   - Place each service spec in `openapi/v{major}/service-name.yml`.  
   - Gateway plugins use the `*-gateway.yml` suffix.

2. **README maintenance**  
   - After adding or updating a spec, update `openapi/README.md`.  
   - Maintain two tables:  
     - **Gateway Plugins** – all plugin specs for the Gateway layer, with owner and completion status.  
     - **Persistence/Typesense** – specs for the Typesense-based persistence layer.  
   - Mark the status column (e.g., ✅/❌) to reflect task completion.

3. **Validation & copyright**  
   - Run the project’s OpenAPI validation tooling after changes.  
   - End every spec with `© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.`

4. **Repository linkage**  
   - Each new gateway spec should have a corresponding Swift package under `libs/GatewayPlugins/` and a registration file `+GatewayPlugin.swift` in `apps/GatewayServer/GatewayApp`.

Following these guidelines keeps OpenAPI specs discoverable, versioned, and consistently integrated with the Gateway and Typesense layers.

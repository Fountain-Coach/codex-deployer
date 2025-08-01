# Integrating Services with the Typesense Client

The Typesense client is generated from the Typesense OpenAPI definition and lives at
`Sources/FountainOps/Generated/Server/Shared/TypesenseClient.swift`. All FountainAI
microservices import this file through the `FountainOps` package.

1. Add `FountainOps` as a dependency in your `Package.swift`:
   ```swift
   .package(path: "../codex-deployer")
   ```
2. Import the client in your service code:
   ```swift
   import FountainOps
   ```
3. Use `TypesenseClient.shared` to store or query data. The client automatically
   picks up `TYPESENSE_URL` and `TYPESENSE_API_KEY` from the environment.

Example:
```swift
let functions = await TypesenseClient.shared.listFunctions()
```

This approach keeps persistence logic consistent across services and allows the
gateway to apply plugins or request transforms before hitting Typesense.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

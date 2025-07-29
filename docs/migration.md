# Repository Migration to Modular SPM Layout

This repository hosts multiple service sources under `repos/`. To match the [Swift‑native modular design](../README.md) we will consolidate these projects into a single Swift package with distinct modules.

## Target Modules

The README lists the following Swift Package Manager modules:

- **FountainCore** – core types and protocols
- **FountainCodex** – agent runtime and dispatcher
- **FountainUI** – Teatro view framework and app shells
- **FountainOps** – Hetzner, DNS, Kong and Typesense utilities
- **FountainAgents** – example agents and helpers

## Repo Mapping

| Current repo path | Destination module | Notes |
|------------------|--------------------|-------|
| `repos/fountainai` | FountainCore / FountainCodex / FountainOps | Split: base types to FountainCore, runtime to FountainCodex, ops scripts to FountainOps |
| `repos/teatro` | FountainUI | Teatro rendering engine |
| `repos/TeatroView`, `repos/TeatroViewPreviewHost`, `repos/TeatroPlayground` | FountainUI | View components and sample apps |
| `repos/kong-codex` | FountainOps | Kong deployment automation |
| `repos/typesense-codex` | FountainOps | Typesense setup utilities |
| others | FountainAgents | Specialised agents or previews |

## Migration Steps

1. **Create module directories** under `Sources/` for each package.
2. **Copy sources** from the existing repos into the corresponding module, preserving history if possible.
3. **Update `Package.swift`** to declare each module as a library or executable and wire up dependencies.
4. **Adjust imports and paths** so that all modules build together using `swift build`.
5. **Remove legacy repos** once the new structure compiles and tests succeed.

----
````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

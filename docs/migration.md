# Repository Migration to Modular SPM Layout

This repository hosts multiple service sources under `repos/`. To match the [Swift‑native modular design](../README.md) we planned to consolidate these projects into a single Swift package with distinct modules. During the attempt we extracted the Teatro code into its own repository at [Fountain-Coach/Teatro](https://github.com/Fountain-Coach/Teatro) where it now builds and tests successfully. The old FountainUI sources remain in this repository under `legacy/` and will be replaced by a new implementation based on that external repository and the templated environment from [FountainAI-Teatro-Template](https://github.com/Fountain-Coach/FountainAI-Teatro-Template).

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
| `repos/teatro` | Extracted to external repo | Moved to [Teatro](https://github.com/Fountain-Coach/Teatro) |
| `repos/TeatroView`, `repos/TeatroViewPreviewHost`, `repos/TeatroPlayground` | Legacy | Sources archived; new FountainUI will rebuild from the Teatro repo |
| `repos/kong-codex` | FountainOps | Kong deployment automation |
| `repos/typesense-codex` | FountainOps | Typesense setup utilities |
| others | FountainAgents | Specialised agents or previews |

## Migration Steps

1. **Create module directories** under `Sources/` for each package.
2. **Copy sources** from the existing repos into the corresponding module, preserving history if possible.
3. **Update `Package.swift`** to declare each module as a library or executable and wire up dependencies.
4. **Adjust imports and paths** so that all modules build together using `swift build`.
5. **Archive FountainUI sources** under `legacy/` and rely on the external [Teatro](https://github.com/Fountain-Coach/Teatro) repository for rebuilding the UI.

## FountainAI Migration Plan

Follow these concrete steps to move `repos/fountainai` into the new modular layout:

1. **Survey current contents** – Identify directories that contain base data models (`Generated`, `OpenAPI`), runtime code generation logic (`FountainAi`, `Makefile`, CLI tools) and deployment helpers (`Scripts`, Dockerfiles).
2. **Create module roots** – Add `Sources/FountainCore`, `Sources/FountainCodex` and `Sources/FountainOps` to the root package.
3. **Move base types** – Copy `Generated/Models.swift` and any reusable protocols or utilities into `Sources/FountainCore`.
4. **Move runtime logic** – Place code generation routines, server kernels and executables under `Sources/FountainCodex`, adjusting imports to reference `FountainCore` where needed.
5. **Move ops scripts** – Transfer Dockerfiles, deployment scripts and helpers to `Sources/FountainOps`.
6. **Update `Package.swift`** – Declare each new target, wire their dependencies and ensure products are exposed as needed.
7. **Refactor imports** – Replace old relative paths with module imports so the code compiles in its new locations.
8. **Build and test** – Run `swift build` then `swift test -v` from the package root to verify all modules compile together.
9. **Deprecate old repo** – Once tests pass, remove `repos/fountainai` and reference the new modules in documentation.
The migration is now complete. All former contents of `repos/fountainai` live under `Sources/` and are built via the root `Package.swift`.

----
````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

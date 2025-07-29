# FountainUI Migration Action Plan

This document expands on [migration.md](migration.md) with a step-by-step checklist for moving all Teatro-based repositories into the `FountainUI` Swift package. Follow these tasks to complete the transition.

## 1. Assess Existing Repositories
- `repos/teatro` – core Teatro rendering engine.
- `repos/TeatroView` – higher level UI components.
- `repos/TeatroViewPreviewHost` – preview target used in Xcode.
- `repos/TeatroPlayground` – Mac sandbox for experimenting with Teatro views.

Review each repo to understand its dependencies, build settings and tests.

## 2. Create the FountainUI Target
1. Add a new directory `Sources/FountainUI` at the repo root.
2. Move the code from the repositories above into subfolders inside `Sources/FountainUI` while keeping their relative paths (e.g. `Sources/FountainUI/Teatro`, `Sources/FountainUI/TeatroView`).
3. Preserve existing package manifests from the repos if they contain useful settings; otherwise consolidate their configuration into `Package.swift`.
4. Ensure the new module exposes a single public library called `FountainUI`.

## 3. Update `Package.swift`
1. Append a `.library(name: "FountainUI", targets: ["FountainUI"])` product.
2. Add a target entry:
   ```swift
   .target(
       name: "FountainUI",
       dependencies: ["FountainCore"],
       path: "Sources/FountainUI"
   ),
   ```
3. If the Teatro code relies on external packages (e.g. SwiftUI previews or scripts), declare them in the dependencies list.

## 4. Refactor Imports
1. Replace any old package names such as `TeatroView` with `FountainUI` throughout the codebase.
2. Adjust paths in Xcode project files if they were committed in the repos.
3. Ensure module visibility is correct so other packages can `import FountainUI`.

## 5. Build and Test
1. Run `swift build` from the repository root to compile all modules together.
2. Execute `swift test -v` to run the unit tests copied from the Teatro repositories and existing tests under `Tests/`.
3. Iterate on compiler errors until the build succeeds and all tests pass.

## 6. Remove Legacy Repositories
1. Once everything compiles, delete the old directories under `repos/` that are now part of `Sources/FountainUI`.
2. Update documentation to point to the new module path instead of the old repos.

## 7. Document Ongoing Maintenance
- Keep `docs/teatro_view_plan.md` and related guides up to date with any changes in APIs or directory layout.
- When adding new views or preview targets, place them under `Sources/FountainUI` and extend `Package.swift` accordingly.

Following this plan will consolidate all UI-related projects under a single SPM module, making the build process faster and the code easier to maintain.

----
````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

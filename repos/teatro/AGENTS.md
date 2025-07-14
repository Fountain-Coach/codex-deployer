# Repository Guidelines

This repository contains the documentation for **Teatro View Engine**, a declarative Swift 6 framework for rendering text, music and screenplay artifacts. The comprehensive docs now live in the `Docs/` directory, one folder per major component. A new `Docs/ImplementationPlan` folder tracks upcoming features and should be updated as development progresses.

## Contributing
- Keep new code modular and follow the structures laid out in `Docs/` and `README.md`.
- Prefer Swift 6 and standard library constructs.
- When adding files, follow the suggested directory structure from the documentation (e.g. `Sources/`, `Tests/`, `CLI/`).
- Include tests under `Tests/` once implementation begins. The repository currently contains only documentation and an empty directory layout.
- Run `swift build` and `swift test` if a `Package.swift` manifest is present.

## Repo Tasks for Codex
- There are currently no automated tests. If you add code, provide appropriate tests and ensure they run via `swift test`.
- Maintain this `AGENTS.md` if repository structure changes.

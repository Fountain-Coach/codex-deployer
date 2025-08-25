# Contributing

## Generated Sources (FountainOps)

This repository references generated client and server sources under `Sources/FountainOps/Generated`.
To allow clean builds, placeholder stubs are checked in. Replace them with your generated code:

- Clients: `Sources/FountainOps/Generated/Client/<service>/{APIClient.swift,APIRequest.swift,Models.swift,Requests/*}`
- Server (shared): `Sources/FountainOps/Generated/Server/Shared/*.swift`
- Server (per service): `Sources/FountainOps/Generated/Server/<service>/*.swift`

Use `scripts/generate_fountainops.sh` as a starting point to wire your generator. This script currently echoes the expected structure and is safe to run.

## Structure

- Apps under `apps/` and libraries under `libs/`.
- Generated code under `internal/` when not required for build; in this project, generated sources live under `Sources/FountainOps/Generated` for build-time visibility.
- Non-code assets live under `docs/` or target `Resources/`.


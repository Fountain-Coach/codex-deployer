# Introduction to Codex-Deployer

*From overview to environment variables.*

Codex-Deployer is an always-on deployment companion built around a simple idea: every build is feedback for the next.

Powered by OpenAI's [Codex](https://platform.openai.com/docs/codex/overview), the dispatcher acts like a **semantic compiler** for infrastructure. It reads build logs, proposes fixes and keeps services coherent. See the official Codex overview for more details.

FountainAI expands this concept into a cross-platform LLM operating system. When fully deployed it will extend Codex and eventually operate independently as a semantic reasoning engine.

The project bundles several FountainAI services and a Python dispatcher that continuously pulls repositories, compiles the code, and reacts to failures. Because all deployment logic lives in Git, you operate it just like any other repository: clone it, edit the configuration, and run the dispatcher.

This introduction summarises the core concepts and explains how environment variables drive the system. Follow the links at the end for deeper dives.

## Core Concepts

1. **Git as the source of truth** – All services live under `repos/` in this repository. The dispatcher pulls updates and commits any changes, so the repo history is the single point of reference.
2. **Python dispatcher loop** – `deploy/dispatcher_v2.py` runs continuously under systemd or inside Docker. It builds services, runs tests, and writes logs under `deploy/logs/`.
3. **Semantic feedback** – After each cycle, JSON placed in `feedback/` can modify the code or restart services. This allows Codex to iterate automatically based on build results.
4. **Cross-platform workflow** – The same loop works on macOS or Linux. Optional Docker Compose tests run when `DISPATCHER_RUN_E2E=1`.

## Configuring the Environment

The dispatcher relies heavily on environment variables for authentication and feature flags. The full list is documented in [environment_variables.md](../environment_variables.md). At minimum you will need a `GITHUB_TOKEN` and commit identity variables (`GIT_USER_NAME`, `GIT_USER_EMAIL`).

For a step-by-step walkthrough of creating `dispatcher.env` and exporting secrets, see [managing_environment_variables.md](../managing_environment_variables.md).

## Managing Platform Diversity

Codex-Deployer runs on both macOS and Linux. The dispatcher detects the host and
chooses the correct Swift toolchain: `xcrun swift` when Xcode is present and the
open source `swift` command elsewhere. You can build the same repository on
either platform without changes.

Two environment variables influence how cross-platform builds behave:

- `SWIFTPM_NUM_JOBS` controls the number of parallel build tasks when running
  `swift test`. Increase it to speed up local compilation on multi-core Macs,
  or lower it on resource-constrained systems.
- `DISPATCHER_RUN_E2E` enables Docker Compose integration tests after the build.
  When set, the dispatcher mounts `/var/run/docker.sock` so containers run on
  the host regardless of whether you are on Linux or macOS.

Refer to [environment_variables.md](../environment_variables.md) for the full
list of options.

## Next Steps

- [Running on macOS with Docker](../mac_docker_tutorial.md) – build the development image and start the dispatcher locally.
- [Local Testing on macOS](../mac_local_testing.md) – mirror the Linux workflow and execute compose-based service tests.
- [Dispatcher v2 Overview](../dispatcher_v2.md) – deep dive into how the loop works and how pull requests are opened.

The [handbook README](README.md) contains a complete table of contents with links to additional background material. For API details see [code_reference.md](code_reference.md).


````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````


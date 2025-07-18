# Introduction to Codex-Deployer

Codex-Deployer is an always-on deployment companion built around a simple idea: every build is feedback for the next. The project bundles several FountainAI services and a Python dispatcher that continuously pulls repositories, compiles the code, and reacts to failures. By keeping the entire deployment logic in Git, the dispatcher acts like a compiler for infrastructure. You operate it just like any other repository: clone it, edit the configuration, and run the dispatcher. This introduction summarises the core concepts and explains how environment variables drive the system. Follow the links at the end of each section for deeper dives.

## Core Concepts

1. **Git as the source of truth** – All services live under `repos/` in this repository. The dispatcher pulls updates and commits any changes, so the repo history is the single point of reference.
2. **Python dispatcher loop** – `deploy/dispatcher_v2.py` runs continuously under systemd or in Docker. It builds services, runs tests, and writes logs under `deploy/logs/`.
3. **Semantic feedback** – After each cycle, JSON placed in `feedback/` can modify the code or restart services. This allows Codex to iterate automatically based on build results.
4. **Optional Docker workflows** – Set `DISPATCHER_BUILD_DOCKER=1` or `DISPATCHER_RUN_E2E=1` to build images and execute `docker compose` integration tests.
5. **Platform diversity** – On macOS the dispatcher uses `xcrun swift` so that Apple SDKs are available. On Linux and inside Docker it defaults to the open source `swift` toolchain. The same repository can be built on either platform without changes.

## Configuring the Environment

The dispatcher relies heavily on environment variables for authentication and feature flags. The full list is documented in [environment_variables.md](../environment_variables.md). At minimum you will need a `GITHUB_TOKEN` and commit identity variables (`GIT_USER_NAME`, `GIT_USER_EMAIL`).

For a step-by-step walkthrough of creating `dispatcher.env` and exporting secrets, see [managing_environment_variables.md](../managing_environment_variables.md).

## Managing Platform Diversity

Codex-Deployer intentionally runs on multiple platforms. The Python dispatcher
detects the host OS and chooses the appropriate Swift toolchain. When running
on macOS it invokes `xcrun swift` so that Xcode's SDKs are available. On Linux
or inside the Docker image it calls the open source `swift` command. You do not
need to change the repository between platforms—the dispatcher adapts
automatically.

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

The [handbook README](README.md) contains a complete table of contents with links to additional background material.

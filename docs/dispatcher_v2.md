# Dispatcher v2.4

`dispatcher_v2.py` is the second major iteration of the Codex deployment loop.
Version 2.4 extends the previous release with build result checks, log rotation,
automatic patch application, a pull request workflow, and platform-aware compilation.

## Key Changes

- **Configurable loop interval** via the `DISPATCHER_INTERVAL` environment
  variable.
- **Structured logging** that timestamps every action.
- **Explicit version tag** accessible via the `__version__` attribute.
- **Log rotation** with timestamped files (`build-YYYYMMDD-HHMMSS.log`).
- **Build/test result reporting** logged to disk.
- **Automatic patch application** and per-repo service restarts.
- **Platform-aware compilation** using the local Xcode toolchain on macOS.
- **Codex-generated commit messages** when `OPENAI_API_KEY` is set.
- **Optional Docker builds & e2e tests** when `DISPATCHER_BUILD_DOCKER` and `DISPATCHER_RUN_E2E` are enabled.

The overall workflow remains the same: repositories are pulled, the FountainAI
service is built, logs are pushed to GitHub and feedback JSON files are applied.

## Usage

The systemd service has been updated to use this version by default:

```ini
ExecStart=/usr/bin/python3 /srv/deploy/deploy/dispatcher_v2.py
```

See the repository [README](../README.md) for setup details and an overview of
the dispatcher's role in the deployment architecture.

The pull request process is documented in [pull_request_workflow.md](pull_request_workflow.md). Set `DISPATCHER_USE_PRS=0` to revert to direct push mode.
Refer to [environment_variables.md](environment_variables.md) for a list of
variables and see
[managing_environment_variables.md](managing_environment_variables.md) for a
step-by-step setup guide, including GitHub token creation. The systemd unit reads values from
`/srv/deploy/dispatcher.env`. Set
`DISPATCHER_BUILD_DOCKER=1` and `DISPATCHER_RUN_E2E=1` to trigger Docker builds
and integration tests after each successful commit or PR merge.


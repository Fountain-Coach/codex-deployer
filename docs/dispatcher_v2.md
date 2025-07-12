# Dispatcher v2.3

`dispatcher_v2.py` is the second major iteration of the Codex deployment loop.
Version 2.3 extends the previous release with build result checks, log rotation,
automatic patch application, and platform-aware compilation.

## Key Changes

- **Configurable loop interval** via the `DISPATCHER_INTERVAL` environment
  variable.
- **Structured logging** that timestamps every action.
- **Explicit version tag** accessible via the `__version__` attribute.
- **Log rotation** with timestamped files (`build-YYYYMMDD-HHMMSS.log`).
- **Build/test result reporting** logged to disk.
- **Automatic patch application** and per-repo service restarts.
- **Platform-aware compilation** using the local Xcode toolchain on macOS.

The overall workflow remains the same: repositories are pulled, the FountainAI
service is built, logs are pushed to GitHub and feedback JSON files are applied.

## Usage

The systemd service has been updated to use this version by default:

```ini
ExecStart=/usr/bin/python3 /srv/deploy/dispatcher_v2.py
```

See the repository [README](../README.md) for setup details and an overview of
the dispatcher's role in the deployment architecture.
\nFor teams that prefer code review via pull requests, see [pull_request_workflow.md](pull_request_workflow.md) for a conceptual guide on extending the dispatcher.

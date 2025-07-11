# Dispatcher v2.0

`dispatcher_v2.py` is the second major iteration of the Codex deployment loop.
It extends the original `dispatcher.py` with clearer documentation and a few
quality of life improvements.

## Key Changes

- **Configurable loop interval** via the `DISPATCHER_INTERVAL` environment
  variable.
- **Structured logging** that timestamps every action.
- **Explicit version tag** accessible via the `__version__` attribute.

The overall workflow remains the same: repositories are pulled, the FountainAI
service is built, logs are pushed to GitHub and feedback JSON files are applied.

## Usage

The systemd service has been updated to use this version by default:

```ini
ExecStart=/usr/bin/python3 /srv/deploy/dispatcher_v2.py
```

See the repository [README](../README.md) for setup details and an overview of
the dispatcher's role in the deployment architecture.

# Environment Variables

This document lists the environment variables used by the Codex deployer.

| Variable | Default | Purpose |
|----------|---------|---------|
| `DISPATCHER_INTERVAL` | `60` | Interval in seconds between dispatcher loops. |
| `DISPATCHER_USE_PRS` | `1` | When set to `0` disables the pull request workflow and pushes directly to `main`. |
| `GITHUB_TOKEN` | _(none)_ | Personal access token used to open pull requests when PR mode is active. |
| `OPENAI_API_KEY` | _(none)_ | Enables AI-generated commit messages when set. |
| `DISPATCHER_BUILD_DOCKER` | `0` | Set to `1` to build Docker images for repos containing a `Dockerfile`. |
| `DISPATCHER_RUN_E2E` | `0` | Set to `1` to run `docker-compose` integration tests when available. |

Variables without defaults are optional but enable additional functionality.
The dispatcher logs a warning at startup if any variable is missing, allowing
you to verify configuration before the main loop begins.

## Using GitHub Secrets

Environment variables can be managed using **GitHub Secrets** so that sensitive
values are not stored in the repository. Create a new secret in your GitHub
repository settings and reference it when running the deployer:

```bash
export GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}"
export OPENAI_API_KEY="${{ secrets.OPENAI_API_KEY }}"
```

The dispatcher reads these variables at startup, so ensure they are exported
before launching the service (e.g. inside your systemd unit file).

## dispatcher.env

The systemd unit loads variables from `/srv/deploy/dispatcher.env`. Copy the
sample from `systemd/dispatcher.env` and edit the values or source your GitHub
secrets there.

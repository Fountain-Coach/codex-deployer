# Environment Variables

This document lists the environment variables used by the Codex deployer.

| Variable | Default | Purpose |
|----------|---------|---------|
| `DISPATCHER_INTERVAL` | `60` | Interval in seconds between dispatcher loops. |
| `DISPATCHER_USE_PRS` | `1` | When set to `0` disables the pull request workflow and pushes directly to `main`. |
| `GITHUB_TOKEN` | _(none)_ | Personal access token used to clone private repositories, push commits, and open pull requests when PR mode is active. |
| `OPENAI_API_KEY` | _(none)_ | Enables AI-generated commit messages and allows the LLM Gateway to access OpenAI's API. |
| `OPENAI_API_BASE` | `https://api.openai.com/v1/chat/completions` | Optional override for the OpenAI API endpoint used by the LLM Gateway. |
| `TYPESENSE_URL` | _(none)_ | Base URL for a running Typesense instance used by FountainAI services. |
| `TYPESENSE_API_KEY` | _(none)_ | Optional API key for authenticating with Typesense. |
| `LLM_GATEWAY_URL` | _(none)_ | Base URL for the LLM Gateway used by the Planner service. |
| `FUNCTION_CALLER_URL` | _(none)_ | Base URL for the Function Caller service invoked by the Planner. |
| `GIT_USER_NAME` | `Contexter` | Used to configure `git config --global user.name`. |
| `GIT_USER_EMAIL` | `mail@benedikt-eickhoff.de` | Used to configure `git config --global user.email`. |
| `DISPATCHER_BUILD_DOCKER` | `0` | Set to `1` to build Docker images for repos containing a `Dockerfile`. |
| `DISPATCHER_RUN_E2E` | `0` | Set to `1` to run `docker-compose` integration tests when available. |
| `SWIFTPM_NUM_JOBS` | `2` | Number of build jobs used by `swift test`. Helps limit CI runner concurrency. |
| `SECRETS_API_URL` | _(none)_ | Endpoint for retrieving secrets at startup. |
| `SECRETS_API_TOKEN` | _(none)_ | Authentication token for the secrets service. |
| `BOOTSTRAP_AUTH_TOKEN` | _(none)_ | Optional bearer token required by the Bootstrap service. |
| `BASELINE_AUTH_TOKEN` | _(none)_ | Optional bearer token required by the Baseline Awareness service. |
| `FUNCTION_CALLER_AUTH_TOKEN` | _(none)_ | Optional bearer token required by the Function Caller service. |
| `TOOLS_FACTORY_AUTH_TOKEN` | _(none)_ | Optional bearer token required by the Tools Factory service. |
| `PLANNER_AUTH_TOKEN` | _(none)_ | Optional bearer token required by the Planner service. |

Variables without defaults are optional but enable additional functionality.
The dispatcher logs a warning at startup if any variable is missing, allowing
you to verify configuration before the main loop begins.

Set `GIT_USER_NAME` and `GIT_USER_EMAIL` to configure the commit identity used
by `git`. This prevents interactive prompts when the dispatcher performs commits.
If these variables are omitted, the dispatcher uses `Contexter` and
`mail@benedikt-eickhoff.de` as defaults.

`GITHUB_TOKEN` should be a personal access token with `repo` and `workflow`
permissions. See GitHub's
[official guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
for instructions and follow
[managing_environment_variables.md](managing_environment_variables.md) for a
step-by-step walk-through of adding it to `dispatcher.env`.
The token is used for cloning repositories, pushing commits, and pulling
updates after pull requests merge so that Git never prompts for a username.

## Using GitHub Secrets

Environment variables can be managed using **GitHub Secrets** so that sensitive
values are not stored in the repository. Create a new secret in your GitHub
repository settings and reference it when running the deployer:

```bash
export GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}"
export OPENAI_API_KEY="${{ secrets.OPENAI_API_KEY }}"
```
export OPENAI_API_BASE="${OPENAI_API_BASE:-https://api.openai.com/v1/chat/completions}"

The dispatcher reads these variables at startup, so ensure they are exported
before launching the service (e.g. inside your systemd unit file).

## dispatcher.env

The systemd unit loads variables from `/srv/deploy/dispatcher.env`. Copy the
sample from `systemd/dispatcher.env` and edit the values or source your GitHub
secrets there. See
[managing_environment_variables.md](managing_environment_variables.md) for a
step-by-step walkthrough of the setup process.

## Security Tips

Secrets such as `GITHUB_TOKEN` should never be committed to the repository.
`dispatcher.env` and other `*.env` files are excluded by `.gitignore` so your
tokens remain private. The accompanying `.dockerignore` file ensures these
values are not copied into Docker build contexts.

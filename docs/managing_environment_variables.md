# Managing Environment Variables

This guide explains how to configure the environment variables required by `dispatcher_v2.py`.
It complements [environment_variables.md](environment_variables.md) with step‑by‑step setup instructions.

## 1. Create `dispatcher.env`

Copy the sample file from `systemd/dispatcher.env` to `/srv/deploy/dispatcher.env`.
This file is loaded by the systemd unit or can be sourced manually when running the dispatcher in Docker.

```bash
cp systemd/dispatcher.env dispatcher.env
```

Edit `dispatcher.env` and fill in your secrets:

```bash
GITHUB_TOKEN=ghp_xxx              # Personal access token for private repos and PRs
OPENAI_API_KEY=sk-xxx             # Optional, enables AI commit messages
DISPATCHER_INTERVAL=60            # Seconds between loops
DISPATCHER_USE_PRS=1              # Set to 0 for direct pushes
GIT_USER_NAME="Contexter"         # Name used for git commits
GIT_USER_EMAIL=mail@benedikt-eickhoff.de  # Email used for git commits
SWIFTPM_NUM_JOBS=2                # Concurrency for swift test (see environment_variables.md)
```

Refer to [environment_variables.md](environment_variables.md) for all available variables and their meanings.

## 2. Generate a GitHub personal access token

1. Sign in to GitHub and open the token settings page:
   [github.com/settings/tokens](https://github.com/settings/tokens) (classic) or
   [github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens)
   for the new interface.
2. Choose **Generate new token** and select *classic* if prompted.
3. Select at least the `repo` and `workflow` scopes so the dispatcher can clone
   private repositories and open pull requests.
4. Click **Generate token** and copy the value.

GitHub provides a walkthrough at their
["Create a personal access token" guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
Paste the token into `dispatcher.env`:

```bash
GITHUB_TOKEN=ghp_xxx
```

## 3. Obtain an OpenAI API key

Visit [OpenAI's API key page](https://platform.openai.com/account/api-keys) and
create a new key if you haven't already. Add it to `dispatcher.env` as
`OPENAI_API_KEY`. This value is optional but enables AI-generated commit
messages.

## 4. Export the variables

Before launching `dispatcher_v2.py`, export the variables from the file:

```bash
set -a
source dispatcher.env
set +a
```

The `set -a` command marks all variables for export so that `python3` inherits them.

## 5. Running inside Docker

You can launch the dispatcher directly on your host or inside the
`codex-deployer-local` image. Running inside Docker keeps the environment
identical across macOS and Linux while still using your host's Docker daemon for
compose-based tests. This mirrors the cross‑platform approach described in the
[handbook introduction](handbook/introduction.md#managing-platform-diversity).

Mount the project directory and pass the exported variables to the container.
The image already bundles the Docker CLI, so mount `/var/run/docker.sock` so it
can talk to the host daemon:

```bash
export $(grep -v '^#' dispatcher.env)
docker run --rm -it -v $(pwd):/srv/deploy \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_TOKEN -e OPENAI_API_KEY \
  codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```

Set `DISPATCHER_RUN_E2E=1` if you want the dispatcher to run each service's
`docker compose` tests. See
[environment_variables.md](environment_variables.md) for a description of this
and other variables.

Using a token avoids interactive Git prompts when cloning private repositories.

## Further Reading

- [environment_variables.md](environment_variables.md) – complete variable reference
- [mac_docker_tutorial.md](mac_docker_tutorial.md) – full walkthrough for macOS

- [handbook](handbook/README.md) – index of all tutorials


````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````


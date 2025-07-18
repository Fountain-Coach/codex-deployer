# Local Testing on macOS

This guide shows how to run the Codex deployer on a Mac so you can execute service tests locally.
It builds a small Docker image and starts `dispatcher_v2.py` with environment variables exported from `dispatcher.env`.
For a broader overview of available guides see [docs/handbook](handbook/README.md).
See [environment_variables.md](environment_variables.md) for the full list of variables.

## 1. Prerequisites

- macOS with [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- Git command line tools

## 2. Clone the repository

```bash
git clone https://github.com/fountain-coach/codex-deployer.git
cd codex-deployer
```

Copy the sample env file and fill in your tokens:

```bash
cp systemd/dispatcher.env dispatcher.env
# edit dispatcher.env with values like GITHUB_TOKEN and OPENAI_API_KEY
```

Follow [managing_environment_variables.md](managing_environment_variables.md) for detailed instructions.

## 3. Build the Docker image

```bash
docker build -t codex-deployer-local .
```

The Dockerfile installs Python, Git and Swift then copies the repository into `/srv/deploy` so the dispatcher runs just like on a server.

## 4. Run the dispatcher with tests
Export the variables and start the container with `DISPATCHER_RUN_E2E=1` to run integration tests. The Docker CLI is installed in the image, but the container needs access to the host daemon. Mount `/var/run/docker.sock` so `docker compose` commands work. See [environment_variables.md](environment_variables.md) for details:

```bash
export $(grep -v '^#' dispatcher.env | xargs)
docker run --rm -it \
  -v $(pwd):/srv/deploy \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_TOKEN -e OPENAI_API_KEY \
  -e DISPATCHER_RUN_E2E=1 \
  -e GIT_USER_NAME -e GIT_USER_EMAIL \
  codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```

The dispatcher runs inside the container, clones the service repositories and executes their build and test commands. Logs appear under `deploy/logs` and are also committed back to GitHub.

## 5. Viewing logs

On your host machine you can inspect the build output:

```bash
ls deploy/logs
cat deploy/logs/build.log
```

To generate a concise error report, run `python3 analyze_swift_log.py` from the repository root. It will produce `report.md` summarizing each log segment. See [README](../README.md#analyzing-swift-logs) for details.

## 6. Stopping

Press `Ctrl-C` in the terminal running the container to stop the dispatcher.

## 7. Further reading

- [mac_docker_tutorial.md](mac_docker_tutorial.md) – more details on running the dispatcher locally
- [environment_variables.md](environment_variables.md) – complete variable reference
- [managing_environment_variables.md](managing_environment_variables.md) – step‑by‑step setup guide

```



```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```

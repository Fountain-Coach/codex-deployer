# Codex-Deployer Handbook

*Git-driven deployment companion for Swift services.*

## Abstract
Codex-Deployer unifies builds, logs, and semantic fixes in a single Git-bound loop. It primarily runs `deploy/dispatcher_v2.py` to build the local **FountainAI** sources vendored under `repos/`. The project began as a pragmatic helper for Codex but ultimately clears the path for FountainAI, a platform where large language models orchestrate tools, analyse knowledge drift, and learn from reflection. As the deployment loop compiles and patches code, it mirrors FountainAI's broader reasoning flow, where plans are executed step by step and every outcome informs the next iteration.

## Table of Contents
- [Introduction to Codex-Deployer](docs/handbook/introduction.md) – overview of the dispatcher and how environment variables shape the workflow.
- [Architecture Overview](docs/handbook/architecture.md) – diagram of repositories and the build loop.
- [Running on macOS with Docker](docs/mac_docker_tutorial.md) – instructions for local Docker setups.
- [Local Testing on macOS](docs/mac_local_testing.md) – guidance for replicating the Linux build on macOS.
- [Managing Environment Variables](docs/managing_environment_variables.md) – how to set up tokens and secrets.
- [Environment Variables Reference](docs/environment_variables.md) – complete list of variables.
- [Dispatcher v2 Overview](docs/dispatcher_v2.md) – inner workings of the Python loop.
- [Pull Request Workflow](docs/pull_request_workflow.md) – how patches are proposed and merged.
- [Code Reference](docs/handbook/code_reference.md) – links to inline API docs.
- [History and Roadmap](docs/handbook/history.md) – how the project evolved and what's next.
- [TeatroPlayground GUI Plan](docs/teatro_playground_gui_plan.md) – draft plan for a Teatro-based GUI.
- [FountainAI Playground Guidelines](docs/fountainai_playground_guidelines.md) – rules for safe UI prototyping.
- [Future Vision](docs/future_vision.md) – long-term FountainAI platform.

## Quick start
Clone the repository, copy the sample environment file, and start the dispatcher in Docker.
```bash
git clone https://github.com/fountain-coach/codex-deployer /srv/deploy
cd /srv/deploy
cp systemd/dispatcher.env dispatcher.env  # edit values
export $(grep -v '^#' dispatcher.env | xargs)
docker build -t codex-deployer-local .
docker run --rm -it \
  -v $(pwd):/srv/deploy \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_TOKEN -e OPENAI_API_KEY \
  codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```
For an explanation of each variable and how to generate tokens, see the [setup guide](docs/managing_environment_variables.md).

## From Codex to FountainAI
Codex-Deployer focuses on deployment. For an overview of the broader FountainAI platform and its APIs, see [docs/future_vision.md](docs/future_vision.md).

`````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
`````

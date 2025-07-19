# Codex-Deployer Handbook

*Git-driven deployment companion for Swift services.*

## Abstract
Codex-Deployer unifies builds, logs, and semantic fixes in a single Git-bound loop. The project began as a pragmatic helper for Codex, but it ultimately clears the path for **FountainAI**, a platform where large language models orchestrate tools, analyse knowledge drift, and learn from reflection. As the deployment loop compiles and patches code, it mirrors FountainAI's broader reasoning flow, where plans are executed step by step and every outcome informs the next iteration.

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
- [Dispatcher Mac GUI Concept](docs/dispatcher_mac_gui_plan.md) – draft plan for a Teatro-based GUI.

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
The dispatcher acts as a **semantic compiler**, applying patches and rebuilding until services succeed. FountainAI takes this approach further. According to the platform overview, it "combines large language models with a suite of specialized services to enable advanced AI reasoning, planning, and knowledge management." Tools are registered, called, and reflected upon so that the AI can improve over time. Our build loop foreshadows that design: after each cycle, the log is parsed, fixes are applied, and the next iteration begins. FountainAI generalizes this idea by orchestrating plans, invoking tools, and storing reflections in corpora, producing "structured multi-step planning" and "automated reflection" for continuous improvement.

Although this repository centers on deployment, the greater vision is an orchestration engine where plans, roles and reflections continually refine the agent's behaviour. For a full introduction, see the [FountainAI Platform Overview PDF](repos/fountainai/Docs/FountainAI%20Platform%20Overview.pdf).

FountainAI aims to unify these services under a persistent reasoning loop that stores knowledge and reflections for long‑term improvement. This repository is just one piece of that puzzle.

## FountainAI OpenAPI Catalog
| Service | Entrypoint | Description | Spec |
| --- | --- | --- | --- |
| Baseline Awareness | http://awareness.fountain.coach/api/v1 | Manages baselines, drift, patterns, reflection data and semantic analytics. | [v1/baseline-awareness.yml](repos/fountainai/FountainAi/openAPI/v1/baseline-awareness.yml) |
| Bootstrap | http://bootstrap.fountain.coach/api/v1 | Initializes corpora, seeds GPT roles and adds baseline snapshots. Relies on the Awareness API to store initial artifacts. | [v1/bootstrap.yml](repos/fountainai/FountainAi/openAPI/v1/bootstrap.yml) |
| Function Caller | http://functions.fountain.coach/api/v1 | Maps OpenAI function-calling plans to HTTP operations. Retrieves definitions from the Tools Factory. | [v1/function-caller.yml](repos/fountainai/FountainAi/openAPI/v1/function-caller.yml) |
| LLM Gateway | http://llm-gateway.fountain.coach/api/v1 | Proxies requests to any LLM with function-calling support. Used by the Planner for LLM-driven tasks. | [v2/llm-gateway.yml](repos/fountainai/FountainAi/openAPI/v2/llm-gateway.yml) |
| Persistence | http://persist.fountain.coach/api/v1 | Typesense-backed store for baselines, drifts, reflections and registered tools. | [v1/persist.yml](repos/fountainai/FountainAi/openAPI/v1/persist.yml) |
| Planner | http://planner.fountain.coach/api/v1 | Orchestrates planning workflows across the LLM Gateway and Function Caller. | [v1/planner.yml](repos/fountainai/FountainAi/openAPI/v1/planner.yml) |
| Tools Factory | http://tools-factory.fountain.coach/api/v1 | Registers new tool definitions in the shared Typesense collection consumed by the Function Caller. | [v1/tools-factory.yml](repos/fountainai/FountainAi/openAPI/v1/tools-factory.yml) |

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

# 🧠 codex-deployer

*Git-driven deployment companion for Swift services.*

Copyright (c) 2025 Benedikte Eickhoff. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.

Codex-Deployer keeps multiple services in lockstep. A small Python loop builds them, logs errors and patches code through Git.

---

## 1. Problem
Deploying several Swift services across Linux and macOS quickly becomes brittle. Every project needs a slightly different toolchain and CI feedback is slow.

## 2. Solution
Codex-Deployer bundles everything in one Git repository. A Python dispatcher pulls the repos, builds each service and commits any fixes. Environment variables configure authentication and optional Docker Compose tests. See [docs/environment_variables.md](docs/environment_variables.md).

## 3. Architecture
The dispatcher loop lives in `deploy/dispatcher_v2.py`. It writes logs to `deploy/logs/` and reads patch proposals from `feedback/`. A diagram and feature list appear in [Architecture Overview](docs/handbook/architecture.md).

## 4. Quick start
```bash
git clone https://github.com/fountain-coach/codex-deployer /srv/deploy
cd /srv/deploy
cp systemd/dispatcher.env dispatcher.env  # edit values
docker build -t codex-deployer-local .
export $(grep -v '^#' dispatcher.env | xargs)
docker run --rm -it \
  -v $(pwd):/srv/deploy \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_TOKEN -e OPENAI_API_KEY \
  codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```
For a full explanation of each variable and how to generate tokens, see [managing_environment_variables.md](docs/managing_environment_variables.md).

## 5. Documentation hub
Start with the [Handbook](docs/handbook/README.md) for tutorials. The [Introduction](docs/handbook/introduction.md) prepares you for the environment setup and cross‑platform workflow. The [Code Reference](docs/handbook/code_reference.md) links to inline docs.

## Key files
| File | Purpose |
| --- | --- |
| `deploy/dispatcher_v2.py` | Main dispatcher loop |
| `docs/handbook/README.md` | Documentation hub |
| `docs/environment_variables.md` | Variable reference |
| `AGENT.md` | Agent behaviour contract |

## Further reading
- [Architecture Overview](docs/handbook/architecture.md)
- [History and Roadmap](docs/handbook/history.md)
- [Code Reference](docs/handbook/code_reference.md)
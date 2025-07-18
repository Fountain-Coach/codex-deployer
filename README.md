# 🧠 codex-deployer

Copyright (c) 2025 Benedikte Eickhoff. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.

Codex-Deployer is a pragmatic deployment companion. It keeps your services in sync by running a small Python loop that builds everything, captures errors and applies fixes from Git.

---

## Overview

Codex-Deployer centralizes multiple Swift services and a Python dispatcher in one repository. It builds the services, applies JSON patches from `feedback/` and pushes results back to GitHub. The same workflow works on macOS or Linux with optional Docker Compose tests.

## Why use it?
Managing multiple Swift services across Linux and macOS can be tedious. CI pipelines are slow and local builds require manual setup. Codex-Deployer places the entire workflow in a single repository so you can drive deployments directly through Git.

## How it works
- `deploy/dispatcher_v2.py` pulls the repos, builds the services and runs tests
- Logs go to `deploy/logs/` and can be analysed with `analyze_swift_log.py`
- JSON files in `feedback/` describe patches; the dispatcher applies them and pushes the result
- Environment variables control behaviour. See [docs/environment_variables.md](docs/environment_variables.md)

For a visual diagram and feature list see [Architecture Overview](docs/handbook/architecture.md).

## Documentation
Start with the [Handbook](docs/handbook/README.md) for tutorials. The [Introduction](docs/handbook/introduction.md) prepares you for the environment setup and cross‑platform workflow. A detailed [Architecture Overview](docs/handbook/architecture.md) expands on the system layout and features. The [Code Reference](docs/handbook/code_reference.md) links to inline docs.

## Quick start
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

## Key files
| File | Purpose |
| --- | --- |
| `deploy/dispatcher_v2.py` | Main dispatcher loop |
| `docs/handbook/README.md` | Documentation hub |
| `docs/environment_variables.md` | Variable reference |
| `agent.md` | Agent behaviour contract |

## Further reading
- [Architecture Overview](docs/handbook/architecture.md)
- [History and Roadmap](docs/handbook/history.md)
- [Code Reference](docs/handbook/code_reference.md)

Released under the [MIT License](LICENSE).

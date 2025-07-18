# 🧠 codex-deployer

*Git-driven deployment companion for Swift services.*

Codex-Deployer orchestrates builds and deployments directly from Git. Powered by
OpenAI's [Codex][codex-doc], it acts like a **semantic compiler**—interpreting
build logs and rewriting code automatically. These foundations pave the way for
FountainAI—a suite of microservices that will extend Codex into a cross-platform
LLM operating system. Once deployed, FountainAI aims to emancipate from Codex
and serve as its own semantic reasoning engine.

Copyright (c) 2025 Benedikte Eickhoff. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.

A minimal Python dispatcher builds each service, logs errors and patches code through Git—keeping every repository in lockstep. This central loop sets up the deployment problem described next.

---

## 1. Problem
Deploying several Swift services across Linux and macOS quickly becomes brittle. Every project needs a slightly different toolchain and CI feedback is slow.
To overcome these hurdles, Codex-Deployer unifies builds, logs and fixes in one workflow.

## 2. Solution
Codex-Deployer bundles everything in one Git repository. A Python dispatcher pulls the repos, builds each service and commits any fixes. Environment variables configure authentication and optional Docker Compose tests[^env-vars].

Understanding how this works requires a quick look at the architecture.

## 3. Architecture
The dispatcher loop lives in `deploy/dispatcher_v2.py`. It writes logs to `deploy/logs/` and reads patch proposals from `feedback/`. A diagram and feature list appear in the architecture overview[^arch-overview].
With these components in mind, you can start the dispatcher locally in a few steps.


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
For a full explanation of each variable and how to generate tokens, see the setup guide[^manage-env].

Once the basics are running, the documentation hub walks you through advanced usage.


## 5. Documentation hub
Start with the handbook[^handbook] for tutorials. The introduction[^intro] prepares you for the environment setup and cross‑platform workflow. The code reference[^code-ref] links to inline docs.

## Key files
| File | Purpose |
| --- | --- |
| `deploy/dispatcher_v2.py` | Main dispatcher loop |
| `docs/handbook/README.md` | Documentation hub |
| `docs/environment_variables.md` | Variable reference |
| `AGENT.md` | Agent behaviour contract |

The references below expand on each topic and trace the project's evolution.

## Further reading
- Architecture overview[^arch-overview]
- History and roadmap[^history]
- Code reference[^code-ref]

[codex-doc]: https://platform.openai.com/docs/codex/overview
[^env-vars]: `docs/environment_variables.md`
[^manage-env]: `docs/managing_environment_variables.md`
[^handbook]: `docs/handbook/README.md`
[^intro]: `docs/handbook/introduction.md`
[^code-ref]: `docs/handbook/code_reference.md`
[^arch-overview]: `docs/handbook/architecture.md`
[^history]: `docs/handbook/history.md`

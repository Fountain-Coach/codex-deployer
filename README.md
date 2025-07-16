# 🧠 codex-deployer

> **The Codex-powered operating system for semantic deployment**

---

## 🌐 Repository: `fountain-coach/codex-deployer`

### 🏷️ Description

A daemonized, Git-native deployment loop designed for FountainAI infrastructure — controlled directly by Codex.

This repo defines a fully autonomous deployment system where Codex:
- Pulls repositories directly via `git`
- Triggers service builds (e.g. `swift build`, `docker compose up`)
- Parses compiler and runtime logs
- Writes structured feedback into a semantic inbox
- Iterates on patches based on the build outcome

An always-on deployment brain powered by Codex.

> **Repo Alias**: References to `fountainai` actually point to
> [`Fountain-Coach/swift-codex-openapi-kernel`](https://github.com/Fountain-Coach/swift-codex-openapi-kernel).
> The sources now reside in `repos/fountainai/`, so no additional clone is required.

---

## 🧠 What is the Codex-Powered Operating System?

This is a **Git-based semantic OS** that lets Codex orchestrate software evolution across services, machines, and configurations by applying reasoning and semantic rules instead of imperative scripts.

At its heart is a single principle:

> **Codex acts as a compiler — the source of truth lives in the repo, and every build becomes feedback for semantic correction.**

---

## 🧩 System Design

```
[ GitHub ]
    ▲
    |   (codex pulls the self-contained repo)
    ▼
[ VPS: FountainAI Node ]
    /srv/deploy/
    ├── repos/
    │   ├── fountainai/       ← Swift + Python services
    │   ├── kong-codex/       ← Gateway config + local Typesense
    │   ├── typesense-codex/  ← Schema definitions + indexing logic
    │   └── teatro/           ← Teatro view engine
    ├── deploy/
    │   └── dispatcher_v2.py   ← Daemonized build + feedback loop
    ├── logs/
    │    └── build.log  ← Swift compiler output
    ├── feedback/
    │    └── codex-001.json  ← Structured GPT feedback
    └── commands/
         ├── restart-services.sh (optional legacy script)
         └── restart-target.sh  ← restart a specific service
```

---

## 🚀 Features

| Capability | Description |
|------------|-------------|
| ✅ Git-native | Codex pulls from `main` and reads current state |
| ✅ Swift compiler integration | Full `swift build`, `swift test`, and `swift run` output is captured |
| ✅ Runs entirely on your VPS | No external runners are required |
| ✅ Semantic feedback loop | Codex writes JSON to `/feedback/`, patches are applied |
| ✅ Daemon architecture | One Python loop drives the whole system |
| ✅ Multi-repo awareness | Includes FountainAI, Kong, Typesense and Teatro sources in one repository |
| ✅ Developer-agnostic | Works whether code was committed by a human or Codex |
| ✅ GitHub sync | Build logs and applied patches automatically pushed |
| ✅ Log rotation | Each cycle writes `build-YYYYMMDD-HHMMSS.log` for history |
| ✅ Platform-aware compilation | Uses `xcrun` on macOS, open source Swift elsewhere |
| ✅ Codex-generated commits | Set `OPENAI_API_KEY` for semantic commit messages |
| ✅ Docker builds & e2e tests | Set `DISPATCHER_BUILD_DOCKER=1` and `DISPATCHER_RUN_E2E=1` to build containers and run integration tests |

---

## 📂 Key Files

| File | Purpose |
|------|---------|
| `dispatcher_v2.py` | The daemon loop (v2.4): pulls repos, builds services, opens PRs by default |
| `logs/latest.log` | Most recent Swift build/test output |
| `logs/build-*.log` | Historical logs for each dispatcher cycle |
| `feedback/` | Codex inbox – write here to apply changes or fix builds |
| `commands/restart-services.sh` | Optional legacy restart script |
| `commands/restart-target.sh` | Restart a service specified in feedback |
| `systemd/fountain-dispatcher.service` | Autostarts dispatcher on VPS boot |
| `docs/dispatcher_v2.md` | Detailed dispatcher v2 documentation |
| `docs/environment_variables.md` | Reference for all environment variables |
| `docs/managing_environment_variables.md` | Step-by-step variable setup |
| `docs/mac_docker_tutorial.md` | Run the dispatcher locally on macOS with Docker |
| `docs/mac_local_testing.md` | Test services locally on macOS |
| `docs/fountainai_mac_ui_plan.md` | Plan for a macOS UI using FountainAI and Teatro |
| `docs/what_is_git.md` | Intro to Git with history and flow |
| `docs/design_patterns.md` | Evaluation of client/server, plugin, and declarative patterns |

---

## ⚡ Setup Instructions

```bash
git clone https://github.com/fountain-coach/codex-deployer /srv/deploy
cd /srv/deploy
sudo cp systemd/fountain-dispatcher.service /etc/systemd/system/
sudo cp systemd/dispatcher.env /srv/deploy/dispatcher.env
sudo nano /srv/deploy/dispatcher.env  # edit values or source secrets
sudo systemctl daemon-reexec
sudo systemctl enable fountain-dispatcher
sudo systemctl start fountain-dispatcher
```

Make sure `/srv/` is writable and owned by the system user running the daemon.
See [docs/environment_variables.md](docs/environment_variables.md) for required
environment variables and GitHub secret configuration. For a detailed token
setup walk-through, including how to create `GITHUB_TOKEN`, consult
[docs/managing_environment_variables.md](docs/managing_environment_variables.md).
Update `/srv/deploy/dispatcher.env` with those values before starting the
service.
Set `GIT_USER_NAME` and `GIT_USER_EMAIL` there to configure the identity used
for commits and avoid interactive Git prompts.
Set `GITHUB_TOKEN` as well to authenticate `git pull` and `git push` commands
without manual prompts. See [docs/environment_variables.md](docs/environment_variables.md)
for details.

The repository's `.gitignore` excludes `dispatcher.env` and other `*.env` files
to keep secrets out of version control. When building images, `.dockerignore`
likewise prevents these files from entering the Docker context.

### Running on macOS

Docker Desktop requires explicit volume sharing. Open **Settings → Resources → File Sharing** and add `/srv/deploy/repos/kong-codex/`. Restart Docker Desktop before running `docker compose` or the Kong configuration mount will fail.

---

## 🧠 How Codex Uses This

Codex can:

- Pull `build.log`, detect Swift errors or drift
- Write feedback JSON like:

```json
{
  "description": "Fix crash due to optional unwrapping",
  "target": "fountainai/bootstrap-service/Sources/InitIn.swift",
  "patch": "guard let corpusId = req.corpusId else { return ... }"
}
```

- On next loop, the dispatcher reads and applies it
- Applied patches and the latest build log are committed and pushed to GitHub

---

## 🧠 Codex + Git = Compiler

This repo is the **Codex compiler runtime** — a deploy tool that unifies reasoning and code in the repository as the source of truth.

You deploy a system that understands itself.

---

## 🗺️ History & Motivation

Codex-deployer began as an experiment to remove brittle CI pipelines and GitHub Actions from the deployment process. It evolved into an always-on, Git-native compiler loop. While it isn't a conventional CI tool, that difference is intentional: the project focuses on reasoning-driven deployments where Codex continually patches and rebuilds services without external runners.

---

## 🏁 Next Steps

- Add webhook triggers or file watchers to speed up feedback cycles
- Build a visual dashboard for log + feedback inspection
- Improve the auto-patch workflow with better conflict handling

---

© FountainCoach — Codex-first infrastructure

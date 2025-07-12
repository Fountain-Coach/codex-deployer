# 🧠 codex-deployer

> **The Codex-powered operating system for semantic deployment**

---

## 🌐 Repository: `fountain-coach/codex-deployer`

### 🏷️ Description

A daemonized, Git-native deployment loop designed for FountainAI infrastructure — controlled by Codex, not GitHub Actions.

This repo defines a fully autonomous deployment system where Codex:
- Pulls repositories directly via `git`
- Triggers service builds (e.g. `swift build`, `docker-compose up`)
- Parses compiler and runtime logs
- Writes structured feedback into a semantic inbox
- Iterates on patches based on the build outcome

No CI runners. No pipelines. Just an always-on deployment brain powered by Codex.

> **Repo Alias**: References to `fountainai` actually point to
> [`Fountain-Coach/swift-codex-openapi-kernel`](https://github.com/Fountain-Coach/swift-codex-openapi-kernel).
> The dispatcher clones it under `/srv/fountainai/` for compatibility until the
> rename is complete.

---

## 🧠 What is the Codex-Powered Operating System?

This is a **Git-based semantic OS** that lets Codex orchestrate software evolution across services, machines, and configurations — using reasoning, not imperative scripts.

At its heart is a single principle:

> **Codex acts as a compiler — the source of truth lives in the repo, and every build becomes feedback for semantic correction.**

---

## 🧩 System Design

```
[ GitHub ]
    ▲
    |   (codex clones repos directly)
    ▼
[ VPS: FountainAI Node ]
    /srv/
    ├── fountainai/          ← Swift + Python services
    ├── kong-codex/          ← Gateway config & plugins
    ├── typesense-codex/     ← Schema definitions + indexing logic
    ├── view-factory/        ← SwiftUI view templates
    └── deploy/
         ├── dispatcher_v2.py   ← Daemonized build + feedback loop
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
| ✅ No runners required | Runs 100% on your VPS |
| ✅ Semantic feedback loop | Codex writes JSON to `/feedback/`, patches are applied |
| ✅ Daemon architecture | One Python loop drives the whole system |
| ✅ Multi-repo awareness | Supports FountainAI, Kong, Typesense, ViewFactory clones in one loop |
| ✅ Developer-agnostic | Works whether code was committed by a human or Codex |
| ✅ GitHub sync | Build logs and applied patches automatically pushed |
| ✅ Log rotation | Each cycle writes `build-YYYYMMDD-HHMMSS.log` for history |
| ✅ Platform-aware compilation | Uses `xcrun` on macOS, open source Swift elsewhere |
| ✅ Codex-generated commits | Set `OPENAI_API_KEY` for semantic commit messages |

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
| `docs/mac_docker_tutorial.md` | Run the dispatcher locally on macOS with Docker |

---

## ⚡ Setup Instructions

```bash
git clone https://github.com/fountain-coach/codex-deployer /srv/deploy
cd /srv/deploy
sudo cp systemd/fountain-dispatcher.service /etc/systemd/system/
sudo systemctl daemon-reexec
sudo systemctl enable fountain-dispatcher
sudo systemctl start fountain-dispatcher
```

Make sure `/srv/` is writable and owned by the system user running the daemon.
See [docs/environment_variables.md](docs/environment_variables.md) for required
environment variables and GitHub secret configuration.

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

This repo is not just a deploy tool.  
It is the **Codex compiler runtime** — where reasoning and code meet in the repo as source-of-truth.

You don’t deploy a system.  
You write one that understands itself.

---

## 🏁 Next Steps

- Add webhook triggers or file watchers to speed up feedback cycles
- Build a visual dashboard for log + feedback inspection
- Improve the auto-patch workflow with better conflict handling

---

© FountainCoach — Codex-first infrastructure

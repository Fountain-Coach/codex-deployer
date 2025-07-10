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
    └── deploy/
         ├── dispatcher.py   ← Daemonized build + feedback loop
         ├── logs/
         │    └── build.log  ← Swift compiler output
         ├── feedback/
         │    └── codex-001.json  ← Structured GPT feedback
         └── commands/
              └── restart-services.sh (optional)
```

---

## 🚀 Features

| Capability | Description |
|------------|-------------|
| ✅ Git-native | Codex pulls from `main` and reads current state |
| ✅ Swift compiler integration | Full `swift build` output is captured and reasoned over |
| ✅ No runners required | Runs 100% on your VPS |
| ✅ Semantic feedback loop | Codex writes JSON to `/feedback/`, gets acted on |
| ✅ Daemon architecture | One Python loop drives the whole system |
| ✅ Multi-repo awareness | Supports FountainAI, Kong, Typesense clones in one loop |
| ✅ Developer-agnostic | Works whether code was committed by a human or Codex |

---

## 📂 Key Files

| File | Purpose |
|------|---------|
| `dispatcher.py` | The daemon loop: pulls repos, builds services, checks for Codex feedback |
| `logs/build.log` | Canonical Swift compiler output for semantic introspection |
| `feedback/` | Codex inbox – write here to apply changes or fix builds |
| `commands/restart-services.sh` | Optional system command triggered by semantic feedback |
| `systemd/fountain-dispatcher.service` | Autostarts dispatcher on VPS boot |

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
- Optional: patches are committed back via `git`

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
- Auto-patch feedback via Codex with commit+push

---

© FountainCoach — Codex-first infrastructure

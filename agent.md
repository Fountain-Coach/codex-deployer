# 🤖 agent.md

> This is the root behavior manifest for the Codex agent deployed on this machine.

---

## 📌 Purpose

This agent runs as a semantic deployment compiler. Its role is to:

- Pull latest GitHub repos (FountainAI, Kong, Typesense)
- Compile services using `swift build` and log output
- Capture build failures and surface them semantically
- Apply feedback patches written by Codex or human developers
- Restart services if needed
- Act as the persistent reasoning loop for infrastructure maintenance

---

## 🧠 Behavior Contract

Codex interacts with this agent via:

- `logs/build.log` → read-only compiler output
- `feedback/*.json` → structured patch proposals
- `commands/restart-services.sh` → optional service restart trigger

The agent never pushes to GitHub directly. Codex submits improvements via PR or local patch.

---

## 📁 Directories

| Path | Purpose |
|------|---------|
| `/srv/fountainai/` | FountainAI services cloned from Git |
| `/srv/kong-codex/` | Kong gateway config + plugins |
| `/srv/typesense-codex/` | Typesense indexing definitions |
| `/srv/deploy/` | Contains `dispatcher.py` and runtime folders |
| `/srv/deploy/logs/` | Build logs from `swift build` |
| `/srv/deploy/feedback/` | Codex-pushed semantic patches |
| `/srv/deploy/commands/` | Optional system hooks (restart, reindex, etc) |

---

## 🛡️ Security Notes

- Agent expects secure SSH access to the VPS
- All Git operations are pull-only unless explicitly patched by Codex
- Feedback files must be vetted and logged

---

## 🔄 Loop Duration

- Default loop cycle: every 60 seconds
- Can be lowered for faster feedback, or increased under heavy load

---

© FountainCoach – Agent is semantic, autonomous, and Git-bound.

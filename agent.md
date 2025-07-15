# 🤖 agent.md

> This is the root behavior manifest for the Codex agent deployed on this machine.

---

## 📌 Purpose

This agent runs as a semantic deployment compiler. Its role is to:

- Build the services from the sources under `repos/`
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

Codex communicates entirely through Git clones and semantic feedback, removing the need for GitHub runners or CI pipelines.

Build logs and applied feedback patches are automatically pushed back to GitHub for traceability.

---

## 📁 Repositories Managed

The agent pulls and manages the following GitHub repositories:

| Repo               | Purpose                                 |
|--------------------|------------------------------------------|
| `fountainai` (alias for `swift-codex-openapi-kernel`) | Swift + Python services (main logic layer) |
| `kong-codex`        | Gateway configuration and plugin definitions |
| `typesense-codex`   | Typesense indexing schemas and bootstrapping logic |
| `codex-deployer`    | This repo — hosts the dispatcher, feedback, and loop logic |
| `teatro`            | Teatro view engine and rendering framework |

> **Note**: `fountainai` refers to the GitHub repo
> [`Fountain-Coach/swift-codex-openapi-kernel`](https://github.com/Fountain-Coach/swift-codex-openapi-kernel).
> The code is vendored under `repos/fountainai/`.
The repositories are included directly rather than as submodules.

---

## 📄 Feedback Format

Codex submits semantic fixes using structured JSON, like:

```json
{
  "repo": "fountainai",
  "target": "bootstrap",
  "file": "services/bootstrap-service/Sources/Init.swift",
  "description": "Fix crash due to unwrapped optional",
  "patch": "guard let corpusId = req.body.corpusId else { return .badRequest }"
}
```

Accepted values for `"repo"`:
- `"fountainai"` → application logic (Swift services)
- `"kong-codex"` → API routes and plugins
- `"typesense-codex"` → schema or search logic
- `"codex-deployer"` → dispatcher logic or system config
- `"teatro"` → Teatro components

---

## 📁 Directories

| Path | Purpose |
|------|---------|
| `/srv/deploy/repos/fountainai/` | FountainAI services |
| `/srv/deploy/repos/kong-codex/` | Kong gateway config + plugins |
| `/srv/deploy/repos/typesense-codex/` | Typesense indexing definitions |
| `/srv/deploy/repos/teatro/` | Teatro view engine |
| `/srv/deploy/` | Contains `dispatcher_v2.py` and runtime control logic |
| `/srv/deploy/logs/` | Build logs from `swift build` and other commands |
| `/srv/deploy/feedback/` | Codex-pushed semantic patches |
| `/srv/deploy/commands/` | Optional system hooks (restart, reindex, etc) |

---

## 🔄 Loop Duration

- Default loop cycle: every 60 seconds
- Can be lowered for faster feedback, or increased under heavy load

---

## 🚦 Test Economization

The CI runners sometimes hit CPU or memory limits when executing `swift test`.
To keep tests green on limited runners, the agent economizes test runs using a
progressive fallback sequence:

1. **No parallelism** – run `swift test --parallel false`.
2. **Cap concurrency** – retry with `--jobs 2` or the `SWIFTPM_NUM_JOBS`
   environment variable (see
   [docs/environment_variables.md](docs/environment_variables.md)).
3. **Split targets** – loop over `swift test --filter <Target>` for each test
   module so heavy modules run in isolation.
4. **Skip heavy cases** – retry with `-DSKIP_SLOW_TESTS` to omit the slowest
   tests when resources are scarce.
5. **Prefer fast tags** – if the suite has tagged tests, run `FastTests` first
   and postpone `SlowTests` to later jobs.
6. **Persist build artifacts** – keep the `.build` directory between runs so
   subsequent retries compile faster.
7. **Fallback runner** – after two failed attempts on the default
   GitHub runner, dispatch the job to a self-hosted runner labeled
   `large-memory`.

---

## 🛡️ Security Notes

- Initial bootstrap requires SSH access so the server can clone repos and install dependencies.
- Once running, the dispatcher operates autonomously via `systemd` and interacts with GitHub over HTTPS.
- All Git operations are pull-only unless Codex submits a feedback patch.
- Feedback files must be vetted and logged.
- `agent.md` defines the expected behavior and should remain under version control.

---

© FountainCoach – Agent is semantic, autonomous, and Git-bound.

# 🧠 Repository Agent Manifest

**Last Updated:** August 04, 2025  
**Scope:** Full-repository self-improvement and orchestration  
**Purpose:** Serve as a machine-actionable contract and coordination center for Codex-driven implementation, testing, and maintenance across all project modules.

---

## 🎯 Mission

This agent maintains an up-to-date view of outstanding development tasks across the entire repository. It exists to bridge declared intent (e.g. specs, interface plans) with verifiable implementation. Each task is described in a structured matrix to allow vertical slice execution and repeatable progress tracking.

---

## 📋 Task Matrix

| Feature                | File(s) or Area                          | Action                                                           | Status | Blockers                                | Tags              |
|------------------------|------------------------------------------|------------------------------------------------------------------|--------|------------------------------------------|-------------------|
| Route53 DNS client     | `Route53Client`                          | Implement DNS operations instead of throwing `Error.unimplemented` | ❌     | Requires AWS DNS API spec and credentials | parser, cli       |
| Generated server handlers | `Sources/*/Handlers`                  | Replace placeholder `HTTPResponse()` returns with functional logic | ✅     | None                                   | server, cli       |
| Supervisor binary paths | `FountainAiLauncher`                   | Package or document required external binaries for supervisor     | ⚠️     | External binaries not included            | deployment, docs  |
| Linter configuration   | root                                     | Introduce SwiftLint setup                 | ✅     | None                                     | ci, linter        |
| CI pipeline            | root                                     | Add CI workflow to run tests and coverage                        | ❌     | Choose CI platform                        | ci, test          |
| Test coverage          | various                                  | Expand tests for under-tested modules (e.g., stubs)              | ⚠️     | Missing implementations, time             | test              |
| Documentation sync     | `docs` vs `code`                         | Update developer docs with actual CLI entrypoints and generators | ⚠️     | Need to audit discrepancies               | docs, cli         |
| OpenAPI specs          | `Sources/FountainOps/FountainAi/openAPI`| Ensure specs reflect implemented endpoints                       | ⚠️     | Spec changes vs code divergence           | parser, docs      |

---

## 🧪 Execution Strategy

Each Codex execution cycle must:
- Select tasks by tag or status
- Implement the feature fully (code, test, docs)
- Verify behavior via `swift test` or CI
- Update `Status` and `Blockers` as resolved

Agents are encouraged to batch tasks by tag (e.g., `cli`, `docs`) and submit atomic pull requests per row or group.

---

## 🔁 Feedback Cycle

After each cycle:
1. Update the matrix in-place
2. Append structured result logs to `/logs/`
3. Track recurring gaps or repeated regressions in `/feedback/`

---

## 📁 Placement

This file must be placed at the **repository root** as `agent.md`.  
It is the canonical manifest governing all self-driven improvement and orchestration logic.

## COPYRIGHT POLICY 🔐

**Mandatory Footer:**  
Every generated or updated file must end with:

> © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


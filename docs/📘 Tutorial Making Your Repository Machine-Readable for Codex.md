# 📘 Tutorial: Making Your Repository Machine-Readable for Codex Agents

> Learn how to turn any existing project into a self-improving, Codex-compatible system by building a task matrix from the inside out — without throwing away your current infrastructure.

---

## ✅ Step 1: Understand the Goal

Our goal is to create a file (usually named `agent.md`) that:

- Lives at the **repo root**
- Contains a **structured task matrix** of actionable improvements
- Tracks `Status`, `Blockers`, `Tags`, and required `File(s)`
- Can be read by humans _or_ Codex-like agents to plan, execute, and report implementation work

---

## 🧠 Step 2: Start With Self-Analysis (Status Quo)

Don't jump straight to the matrix. Begin by asking Codex:

```text
Please analyze this repository and report the current status quo in terms of:

1. Supported input formats or interfaces
2. Output renderers or transformations
3. CLI or API entrypoints
4. Existing test coverage
5. Documented specs vs implemented code
6. Linter and CI presence
7. Known gaps or TODOs

Output a structured status report in Markdown.

💡 Why? This lets Codex build an accurate map of what exists, what’s incomplete, and what’s missing — based on real code, not assumptions.

⸻

📋 Step 3: Translate Status into a Task Matrix

Use the status report to prompt:

Now create a machine-readable task matrix from this status report.

Each row should represent a discrete unit of implementation or alignment.  
Use this format:

| Feature | File(s) or Area | Action | Status | Blockers | Tags |

Use emoji for `Status`: ✅ (done), ⏳ (todo), ⚠️ (partial), ❌ (missing)
Use `Tags` to group related work: parser, cli, docs, test, ci, etc.

📌 Save this result as agent.md at the repo root.

⸻

🛠 Step 4: Use the Matrix to Drive Execution

Now you can ask Codex:

Please select any 2 rows tagged `parser` and fully implement them.

Each task must:
- Update the actual source code
- Add tests and docs if needed
- Pass `swift test` or `pytest`
- Update `agent.md` Status
- Append a commit log

This enforces vertical slice completion and avoids shallow “next step” traps.

⸻

🔁 Step 5: Maintain the Feedback Loop

Codex or human agents should:
	•	Regularly update the Status column
	•	Add comments to Blockers as things become clearer
	•	Submit changes as structured pull requests
	•	Archive logs in /logs/ and feedback in /feedback/ folders

⸻

📂 Example agent.md (Minimal Seed)

# 🧠 Repository Agent Manifest

| Feature             | File(s)          | Action     | Status | Blockers                     | Tags         |
|---------------------|------------------|------------|--------|------------------------------|--------------|
| Linter config       | root              | Introduce  | ❌     | Choose a Swift linter        | linter, ci   |
| CLI entrypoint docs | docs vs CLI code | Sync       | ⚠️     | CLI flags not documented     | docs, cli    |
| CI workflow         | .github/          | Add        | ❌     | Platform not yet selected    | ci, test     |


⸻

🧠 Best Practices
	•	✅ Use tags to enable batching by theme (e.g. all docs, all cli)
	•	✅ Keep tasks small enough to complete in a single PR
	•	✅ Encourage Codex to append result logs
	•	✅ Use Status emoji to make scanning easy
	•	✅ Treat agent.md as a living manifest — not a spec dump

⸻

🎯 Outcome

Once in place, this system lets Codex:
	•	Plan intelligently
	•	Act repeatedly
	•	Self-update progressively

…without ever starting over or forgetting past progress.

⸻

🪄 Ready to Begin?

Start by running the status report prompt from Step 2 in your Codex shell or planner loop. Let Codex describe what your repo actually is.

Then build the matrix.

Then evolve.

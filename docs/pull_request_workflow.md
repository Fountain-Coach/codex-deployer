# Pull Request Workflow

Dispatcher v2.4 enables a pull request workflow by default. Set the environment variable `DISPATCHER_USE_PRS=0` if you prefer direct pushes.

When PR mode is active the dispatcher:

1. **Creates a branch** when applying patches or log updates.
2. **Pushes that branch** to GitHub instead of committing to `main`.
3. **Opens a pull request** from the new branch to the target branch using the GitHub API or `gh` CLI.
4. **Waits for merge**. The dispatcher should poll for the PR status and only continue once it has been merged.
5. **Pulls the updated branch** and resumes its normal build cycle.

This approach allows human review while keeping automation centralized. Direct push mode remains available by disabling `DISPATCHER_USE_PRS`.

```` text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

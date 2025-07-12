# Pull Request Workflow Concept

The default dispatcher pushes commits directly to the repository branch it manages. This keeps the deployment loop simple but may be too permissive for some teams.

If you would rather have Codex propose changes through pull requests, modify `dispatcher_v2.py` so that it:

1. **Creates a branch** when applying patches or log updates.
2. **Pushes that branch** to GitHub instead of committing to `main`.
3. **Opens a pull request** from the new branch to the target branch using the GitHub API or `gh` CLI.
4. **Waits for merge**. The dispatcher should poll for the PR status and only continue once it has been merged.
5. **Pulls the updated branch** and resumes its normal build cycle.

This approach allows human code review while still keeping the automation centralized. The dispatcher does not implement this behavior by default—it's an optional extension you can layer on top of version 2.3.

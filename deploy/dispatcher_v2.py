"""Dispatcher v2.4
===================

An improved deployment dispatcher for Codex. Version 2.4 adds

basic build result checking, log rotation, automatic patch
application, and granular service restarts. It remains backward
compatible with the original :mod:`dispatcher` but exposes a new
entry point.
"""

import os
import subprocess
import time
import json
from datetime import datetime
import sys
import urllib.request
import urllib.error

# Managed repositories now live directly under ``repos/`` in this repository.
REPO_NAMES = ["fountainai", "kong-codex", "typesense-codex", "teatro"]
REPOS_DIR = "/srv/deploy/repos"
from codex_changelog import generate_commit_message, append_changelog

__version__ = "2.4"


LOG_DIR = "/srv/deploy/logs"
FEEDBACK_DIR = "/srv/deploy/feedback"

# ``LOG_LATEST`` is a stable path that always points to the most recent build
# log. ``LOG_FILE`` will be updated each cycle to a timestamped file and copied
# to ``LOG_LATEST`` for backwards compatibility.
LOG_LATEST = os.path.join(LOG_DIR, "build.log")
LOG_FILE = LOG_LATEST
# See docs/environment_variables.md for details on these variables
LOOP_INTERVAL = int(os.environ.get("DISPATCHER_INTERVAL", "60"))
USE_PRS = os.environ.get("DISPATCHER_USE_PRS", "1").lower() not in {"0", "false", "no"}
BUILD_DOCKER = os.environ.get("DISPATCHER_BUILD_DOCKER", "0").lower() not in {"0", "false", "no"}
# docker and docker compose must be available inside the container when running integration tests
RUN_E2E = os.environ.get("DISPATCHER_RUN_E2E", "0").lower() not in {"0", "false", "no"}

# Defaults for git identity when environment variables are missing.
# See docs/environment_variables.md for details.
DEFAULT_GIT_NAME = "Contexter"
DEFAULT_GIT_EMAIL = "mail@benedikt-eickhoff.de"


def configure_git() -> None:
    """Set global git identity, falling back to defaults."""
    name = os.environ.get("GIT_USER_NAME", DEFAULT_GIT_NAME)
    email = os.environ.get("GIT_USER_EMAIL", DEFAULT_GIT_EMAIL)
    subprocess.run(["git", "config", "--global", "user.name", name], check=False)
    subprocess.run(["git", "config", "--global", "user.email", email], check=False)
    if os.environ.get("GIT_USER_NAME") is None:
        log(f"GIT_USER_NAME not set; defaulting to {name}")
    if os.environ.get("GIT_USER_EMAIL") is None:
        log(f"GIT_USER_EMAIL not set; defaulting to {email}")


def check_env() -> None:
    """Log the availability of environment variables."""
    if "DISPATCHER_INTERVAL" not in os.environ:
        log("DISPATCHER_INTERVAL not set; using default 60")
    if "DISPATCHER_USE_PRS" not in os.environ:
        log("DISPATCHER_USE_PRS not set; pull request workflow enabled")
    if "GITHUB_TOKEN" not in os.environ:
        log("GITHUB_TOKEN not set; PR creation will be skipped")
    if "OPENAI_API_KEY" not in os.environ:
        log("OPENAI_API_KEY not set; commit messages will be generic")
    if "DISPATCHER_BUILD_DOCKER" not in os.environ:
        log("DISPATCHER_BUILD_DOCKER not set; docker builds disabled")
    if "DISPATCHER_RUN_E2E" not in os.environ:
        log("DISPATCHER_RUN_E2E not set; integration tests disabled")


def ensure_dirs() -> None:
    """Create required directories if they do not exist."""
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(FEEDBACK_DIR, exist_ok=True)


def start_new_log() -> None:
    """Create a fresh timestamped log file and update ``LOG_FILE``."""
    global LOG_FILE
    ensure_dirs()
    ts = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    LOG_FILE = os.path.join(LOG_DIR, f"build-{ts}.log")
    # keep a stable latest log for external tools
    if os.path.exists(LOG_LATEST):
        os.remove(LOG_LATEST)
    open(LOG_FILE, "a").close()
    subprocess.run(["cp", LOG_FILE, LOG_LATEST], check=False)


def timestamp() -> str:
    """Return the current timestamp in ISO format."""
    return datetime.utcnow().isoformat()


def log(msg: str) -> None:
    """Append a log message to ``LOG_FILE`` and echo to the console."""
    line = f"[{timestamp()}] {msg}"
    with open(LOG_FILE, "a") as fh:
        fh.write(line + "\n")
    print(line, flush=True)


def _repo_slug(repo_path: str) -> str:
    """Return the ``owner/repo`` slug for the given repository path."""
    result = subprocess.run(
        ["git", "-C", repo_path, "config", "--get", "remote.origin.url"],
        capture_output=True,
        text=True,
        check=False,
    )
    url = result.stdout.strip()
    if not url:
        return ""
    if url.startswith("git@"):
        slug = url.split(":", 1)[1]
    else:
        slug = url.split("github.com/")[-1]
    if slug.endswith(".git"):
        slug = slug[:-4]
    return slug


def _create_pr(slug: str, branch: str, title: str, base: str = "main") -> int:
    """Open a pull request and return its number, or -1 on failure."""
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        log("GITHUB_TOKEN not set; skipping PR creation")
        return -1
    data = json.dumps({"title": title, "head": branch, "base": base}).encode()
    req = urllib.request.Request(
        f"https://api.github.com/repos/{slug}/pulls",
        data=data,
        headers={
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github+json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode()
        pr_number = json.loads(body).get("number", -1)
        if pr_number != -1:
            log(f"Opened PR #{pr_number} for {slug}")
        else:
            log(f"Failed to parse PR creation response: {body}")
        return pr_number
    except urllib.error.HTTPError as e:
        log(f"Failed to create PR for {slug}: {e.reason}")
    except Exception as e:
        log(f"Failed to create PR for {slug}: {str(e)}")
    return -1


def _wait_for_merge(slug: str, pr_number: int, interval: int = 30) -> None:
    """Poll the PR until it has been merged."""
    token = os.environ.get("GITHUB_TOKEN")
    if pr_number < 0 or not token:
        log("Skipping merge wait; missing PR number or token")
        return
    url = f"https://api.github.com/repos/{slug}/pulls/{pr_number}"
    req = urllib.request.Request(
        url,
        headers={
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github+json",
        },
    )
    while True:
        try:
            with urllib.request.urlopen(req) as resp:
                data = json.loads(resp.read().decode())
        except urllib.error.HTTPError as e:
            log(f"Failed to fetch PR status: {e.reason}")
            time.sleep(interval)
            continue
        except Exception as e:
            log(f"Invalid PR status response: {str(e)}")
            time.sleep(interval)
            continue
        if data.get("merged"):
            log(f"PR #{pr_number} merged")
            break
        if data.get("state") == "closed" and not data.get("merged"):
            log(f"PR #{pr_number} closed without merge")
            break
        time.sleep(interval)


def _update_remote_with_token(repo_path: str, slug: str) -> None:
    """Set the repo's ``origin`` remote to use HTTPS with the GitHub token.

    This avoids interactive authentication prompts when running in a
    container. See ``docs/environment_variables.md`` for details on
    ``GITHUB_TOKEN``.
    """
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        log("GITHUB_TOKEN not set; cannot rewrite git remote")
        return
    url = f"https://x-access-token:{token}@github.com/{slug}.git"
    subprocess.run([
        "git",
        "-C",
        repo_path,
        "remote",
        "set-url",
        "origin",
        url,
    ], check=False)
    log("[dispatcher] Updated git remote to use token-based authentication.")


def commit_and_push(message: str, base: str = "main") -> bool:
    """Commit staged changes to the ``codex-deployer`` repo and push upstream.

    Returns ``True`` when the push succeeds."""
    repo_path = "/srv/deploy"
    subprocess.run(["git", "-C", repo_path, "add", "-A"], check=False)
    message = generate_commit_message(repo_path, message)
    append_changelog(repo_path, message)
    current_branch = (
        subprocess.run(
            ["git", "-C", repo_path, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
            check=False,
        ).stdout.strip()
        or base
    )
    branch = current_branch
    if USE_PRS:
        branch = f"codex-{int(time.time())}"
        subprocess.run(["git", "-C", repo_path, "checkout", "-b", branch], check=False)
    commit_result = subprocess.run(["git", "-C", repo_path, "commit", "-m", message], check=False)
    if commit_result.returncode != 0:
        log(f"git commit failed with exit code {commit_result.returncode}")
        return False
    token = os.environ.get("GITHUB_TOKEN")
    slug = _repo_slug(repo_path)
    _update_remote_with_token(repo_path, slug)
    if USE_PRS:
        push_cmd = ["git", "-C", repo_path, "push", "-u"]
        if token:
            # Use a tokenized URL for pushes to avoid interactive prompts.
            # See docs/environment_variables.md for details on GITHUB_TOKEN.
            push_cmd.append(f"https://x-access-token:{token}@github.com/{slug}.git")
        else:
            push_cmd.append("origin")
        push_cmd.append(branch)
        push_result = subprocess.run(push_cmd, check=False)
        if push_result.returncode != 0:
            log(f"git push failed with exit code {push_result.returncode}")
            return False
        pr = _create_pr(slug, branch, message, base)
        _wait_for_merge(slug, pr)
        subprocess.run(["git", "-C", repo_path, "checkout", base], check=False)
        pull_cmd = ["git", "-C", repo_path, "pull"]
        if token:
            pull_cmd.append(f"https://x-access-token:{token}@github.com/{slug}.git")
        subprocess.run(pull_cmd, check=False)
    else:
        push_cmd = ["git", "-C", repo_path, "push"]
        if token:
            push_cmd.append(f"https://x-access-token:{token}@github.com/{slug}.git")
        push_result = subprocess.run(push_cmd, check=False)
        if push_result.returncode != 0:
            log(f"git push failed with exit code {push_result.returncode}")
            return False
    return True


def push_logs_to_github() -> None:
    """Commit and push the latest build log to the ``codex-deployer`` repo."""
    latest_log = os.path.join("/srv/deploy", "logs", "latest.log")
    os.makedirs(os.path.dirname(latest_log), exist_ok=True)
    subprocess.run(["cp", LOG_FILE, latest_log], check=False)
    subprocess.run(
        [
            "git",
            "-C",
            "/srv/deploy",
            "add",
            f"logs/{os.path.basename(LOG_FILE)}",
            "logs/latest.log",
        ],
        check=False,
    )
    if commit_and_push(f"Update build log {os.path.basename(LOG_FILE)}: {timestamp()}"):
        run_post_commit_hooks()




def build_swift() -> None:
    """Run ``swift build`` and ``swift test`` for the FountainAI repository."""
    with open(LOG_FILE, "a") as fh:
        fh.write(f"\n[{timestamp()}] Starting swift build...\n")
        build_cmd = ["swift", "build"]
        if sys.platform == "darwin":
            # Prefer the local Xcode toolchain when available
            build_cmd = ["xcrun", "swift", "build"]
        repo_path = os.path.join(REPOS_DIR, "fountainai")
        build_result = subprocess.run(
            build_cmd,
            cwd=repo_path,
            stdout=fh,
            stderr=subprocess.STDOUT,
        )
        if build_result.returncode == 0:
            fh.write(f"[{timestamp()}] swift build succeeded\n")
            if os.path.exists(os.path.join(repo_path, "Tests")):
                fh.write(f"[{timestamp()}] running swift test...\n")
                test_cmd = ["swift", "test"]
                if sys.platform == "darwin":
                    test_cmd = ["xcrun", "swift", "test"]
                test_result = subprocess.run(
                    test_cmd,
                    cwd=repo_path,
                    stdout=fh,
                    stderr=subprocess.STDOUT,
                )
                if test_result.returncode == 0:
                    fh.write(f"[{timestamp()}] swift test succeeded\n")
                else:
                    fh.write(f"[{timestamp()}] swift test failed with exit code {test_result.returncode}\n")
        else:
            fh.write(f"[{timestamp()}] swift build failed with exit code {build_result.returncode}\n")


def build_docker_images() -> None:
    """Build Docker images for any repository containing a Dockerfile."""
    if not BUILD_DOCKER:
        return
    log("[dispatcher] Running Docker build...")
    with open(LOG_FILE, "a") as fh:
        for alias in REPO_NAMES:
            repo_path = os.path.join(REPOS_DIR, alias)
            dockerfile = os.path.join(repo_path, "Dockerfile")
            if os.path.exists(dockerfile):
                fh.write(f"\n[{timestamp()}] Building Docker image for {alias}...\n")
                tag = f"{alias}:latest"
                result = subprocess.run(
                    ["docker", "build", "-t", tag, "."],
                    cwd=repo_path,
                    stdout=fh,
                    stderr=subprocess.STDOUT,
                )
                if result.returncode == 0:
                    fh.write(f"[{timestamp()}] Docker build for {alias} succeeded\n")
                else:
                    fh.write(
                        f"[{timestamp()}] Docker build for {alias} failed with exit code {result.returncode}\n"
                    )


def run_e2e_tests() -> None:
    """Run docker compose integration tests if a compose file is present."""
    if not RUN_E2E:
        return
    log("[dispatcher] Running tests...")
    with open(LOG_FILE, "a") as fh:
        for alias in REPO_NAMES:
            repo_path = os.path.join(REPOS_DIR, alias)
            compose_file = os.path.join(repo_path, "docker-compose.yml")
            if os.path.exists(compose_file):
                fh.write(f"\n[{timestamp()}] Running integration tests for {alias}...\n")
                result = subprocess.run(
                    ["docker", "compose", "up", "--build", "--abort-on-container-exit"],
                    cwd=repo_path,
                    stdout=fh,
                    stderr=subprocess.STDOUT,
                )
                subprocess.run([
                    "docker",
                    "compose",
                    "down",
                    "--remove-orphans",
                ], cwd=repo_path, stdout=fh, stderr=subprocess.STDOUT)
                if result.returncode == 0:
                    fh.write(f"[{timestamp()}] Integration tests for {alias} succeeded\n")
                else:
                    fh.write(
                        f"[{timestamp()}] Integration tests for {alias} failed with exit code {result.returncode}\n"
                    )


def run_post_commit_hooks() -> None:
    """Run optional build and test steps after a commit or PR."""
    try:
        if BUILD_DOCKER:
            build_docker_images()
        if RUN_E2E:
            run_e2e_tests()
    except Exception as exc:
        log(f"Post-commit hooks failed: {exc}")


def commit_applied_patch(fname: str) -> None:
    """Mark a feedback JSON file as applied and push it upstream."""
    patch_path = os.path.join(FEEDBACK_DIR, fname)
    new_name = f"applied-{fname}"
    new_path = os.path.join(FEEDBACK_DIR, new_name)
    os.rename(patch_path, new_path)
    subprocess.run(["git", "-C", "/srv/deploy", "add", f"feedback/{new_name}"], check=False)
    if commit_and_push(f"Applied patch: {fname}"):
        run_post_commit_hooks()


def apply_codex_feedback() -> None:
    """Consume any pending JSON feedback files from ``FEEDBACK_DIR``."""
    for fname in os.listdir(FEEDBACK_DIR):
        if not fname.endswith(".json"):
            continue

        log(f"Codex feedback detected: {fname}")
        fpath = os.path.join(FEEDBACK_DIR, fname)
        try:
            with open(fpath, "r") as fh:
                data = json.load(fh)
        except Exception as exc:  # malformed JSON
            log(f"Failed to parse {fname}: {exc}")
            commit_applied_patch(fname)
            continue

        repo = data.get("repo", "fountainai")
        patch = data.get("patch", "")
        desc = data.get("description", f"Apply patch {fname}")
        repo_path = os.path.join(REPOS_DIR, repo)

        if patch:
            result = subprocess.run(
                ["git", "-C", repo_path, "apply", "-"],
                input=patch.encode(),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            if result.returncode == 0:
                subprocess.run(["git", "-C", repo_path, "add", "-A"], check=False)
                commit_and_push(desc)
                log(f"Patch applied to {repo}: {desc}")
            else:
                log(
                    f"Failed to apply patch {fname} to {repo}: {result.stderr.decode().strip()}"
                )
        else:
            log(f"No patch field in {fname}")

        restart_script = f"/srv/deploy/commands/restart-{repo}.sh"
        if os.path.exists(restart_script):
            subprocess.run(["bash", restart_script], check=False)
        else:
            subprocess.run(["bash", "/srv/deploy/commands/restart-services.sh"], check=False)

        commit_applied_patch(fname)


def loop() -> None:
    """Main dispatcher loop."""
    ensure_dirs()
    start_new_log()
    check_env()
    configure_git()
    log("Dispatcher started successfully \U0001F7E2")
    while True:
        log("=== New Cycle ===")
        build_swift()
        push_logs_to_github()
        apply_codex_feedback()
        time.sleep(LOOP_INTERVAL)
        start_new_log()


if __name__ == "__main__":
    loop()


"""Dispatcher v2.3
===================

An improved deployment dispatcher for Codex. Version 2.3 adds
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
from typing import Dict
import sys

from repo_config import REPOS, ALIASES

__version__ = "2.3"

LOG_DIR = "/srv/deploy/logs"
FEEDBACK_DIR = "/srv/deploy/feedback"

# ``LOG_LATEST`` is a stable path that always points to the most recent build
# log. ``LOG_FILE`` will be updated each cycle to a timestamped file and copied
# to ``LOG_LATEST`` for backwards compatibility.
LOG_LATEST = os.path.join(LOG_DIR, "build.log")
LOG_FILE = LOG_LATEST
LOOP_INTERVAL = int(os.environ.get("DISPATCHER_INTERVAL", "60"))


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
    """Append a log message to ``LOG_FILE`` with a timestamp."""
    with open(LOG_FILE, "a") as fh:
        fh.write(f"[{timestamp()}] {msg}\n")


def push_logs_to_github() -> None:
    """Commit and push the latest build log to the ``codex-deployer`` repo."""
    latest_log = os.path.join("/srv/deploy", "logs", "latest.log")
    os.makedirs(os.path.dirname(latest_log), exist_ok=True)
    subprocess.run(["cp", LOG_FILE, latest_log], check=False)
    subprocess.run(["git", "-C", "/srv/deploy", "add", f"logs/{os.path.basename(LOG_FILE)}", "logs/latest.log"], check=False)
    subprocess.run(
        [
            "git",
            "-C",
            "/srv/deploy",
            "commit",
            "-m",
            f"Update build log {os.path.basename(LOG_FILE)}: {timestamp()}",
        ],
        check=False,
    )
    subprocess.run(["git", "-C", "/srv/deploy", "push"], check=False)


def pull_repos(repos: Dict[str, str]) -> None:
    """Clone or update all configured repositories."""
    for alias, url in repos.items():
        path = f"/srv/{alias}"
        canonical = ALIASES.get(alias, alias)
        if not os.path.exists(path):
            subprocess.run(["git", "clone", url, path], check=False)
            log(f"Cloned {alias} -> {canonical}")
        else:
            subprocess.run(["git", "-C", path, "pull"], check=False)
            log(f"Pulled latest {alias} -> {canonical}")


def build_swift() -> None:
    """Run ``swift build`` and ``swift test`` for the FountainAI repository."""
    with open(LOG_FILE, "a") as fh:
        fh.write(f"\n[{timestamp()}] Starting swift build...\n")
        build_cmd = ["swift", "build"]
        if sys.platform == "darwin":
            # Prefer the local Xcode toolchain when available
            build_cmd = ["xcrun", "swift", "build"]
        build_result = subprocess.run(
            build_cmd,
            cwd="/srv/fountainai",
            stdout=fh,
            stderr=subprocess.STDOUT,
        )
        if build_result.returncode == 0:
            fh.write(f"[{timestamp()}] swift build succeeded\n")
            if os.path.exists(os.path.join("/srv/fountainai", "Tests")):
                fh.write(f"[{timestamp()}] running swift test...\n")
                test_cmd = ["swift", "test"]
                if sys.platform == "darwin":
                    test_cmd = ["xcrun", "swift", "test"]
                test_result = subprocess.run(
                    test_cmd,
                    cwd="/srv/fountainai",
                    stdout=fh,
                    stderr=subprocess.STDOUT,
                )
                if test_result.returncode == 0:
                    fh.write(f"[{timestamp()}] swift test succeeded\n")
                else:
                    fh.write(f"[{timestamp()}] swift test failed with exit code {test_result.returncode}\n")
        else:
            fh.write(f"[{timestamp()}] swift build failed with exit code {build_result.returncode}\n")


def commit_applied_patch(fname: str) -> None:
    """Mark a feedback JSON file as applied and push it upstream."""
    patch_path = os.path.join(FEEDBACK_DIR, fname)
    new_name = f"applied-{fname}"
    new_path = os.path.join(FEEDBACK_DIR, new_name)
    os.rename(patch_path, new_path)
    subprocess.run(["git", "-C", "/srv/deploy", "add", f"feedback/{new_name}"], check=False)
    subprocess.run(
        ["git", "-C", "/srv/deploy", "commit", "-m", f"Applied patch: {fname}"], check=False
    )
    subprocess.run(["git", "-C", "/srv/deploy", "push"], check=False)


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
        repo_path = f"/srv/{repo}"

        if patch:
            result = subprocess.run(
                ["git", "-C", repo_path, "apply", "-"],
                input=patch.encode(),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            if result.returncode == 0:
                subprocess.run(["git", "-C", repo_path, "add", "-A"], check=False)
                subprocess.run([
                    "git",
                    "-C",
                    repo_path,
                    "commit",
                    "-m",
                    desc,
                ], check=False)
                subprocess.run(["git", "-C", repo_path, "push"], check=False)
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
    while True:
        start_new_log()
        log("=== New Cycle ===")
        pull_repos(REPOS)
        build_swift()
        push_logs_to_github()
        apply_codex_feedback()
        time.sleep(LOOP_INTERVAL)


if __name__ == "__main__":
    loop()


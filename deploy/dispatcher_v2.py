"""Dispatcher v2.0
===================

An improved deployment dispatcher for Codex. This version introduces
structured logging, configurable loop intervals, and clearer function
documentation. It remains backward compatible with the original
:mod:`dispatcher` but exposes a new entry point.
"""

import os
import subprocess
import time
from datetime import datetime
from typing import Dict

from repo_config import REPOS, ALIASES

__version__ = "2.0"

LOG_DIR = "/srv/deploy/logs"
FEEDBACK_DIR = "/srv/deploy/feedback"
LOG_FILE = os.path.join(LOG_DIR, "build.log")
LOOP_INTERVAL = int(os.environ.get("DISPATCHER_INTERVAL", "60"))


def ensure_dirs() -> None:
    """Create required directories if they do not exist."""
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(FEEDBACK_DIR, exist_ok=True)


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
    subprocess.run(["git", "-C", "/srv/deploy", "add", "logs/latest.log"], check=False)
    subprocess.run(
        ["git", "-C", "/srv/deploy", "commit", "-m", f"Update build log: {timestamp()}"] ,
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
    """Run ``swift build`` inside the FountainAI repository."""
    with open(LOG_FILE, "a") as fh:
        fh.write(f"\n[{timestamp()}] Starting swift build...\n")
        subprocess.run(
            ["swift", "build"], cwd="/srv/fountainai", stdout=fh, stderr=subprocess.STDOUT, check=False
        )


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
        if fname.endswith(".json"):
            log(f"Codex feedback detected: {fname}")
            subprocess.run(["bash", "/srv/deploy/commands/restart-services.sh"], check=False)
            commit_applied_patch(fname)


def loop() -> None:
    """Main dispatcher loop."""
    ensure_dirs()
    while True:
        log("=== New Cycle ===")
        pull_repos(REPOS)
        build_swift()
        push_logs_to_github()
        apply_codex_feedback()
        time.sleep(LOOP_INTERVAL)


if __name__ == "__main__":
    loop()


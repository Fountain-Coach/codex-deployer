"""Copy configured repositories into ``repos/`` as a monorepo snapshot.

This script clones each repository defined in :mod:`deploy.repo_config` and
copies its working tree (without ``.git``) into a ``repos/`` directory at the
root of ``codex-deployer``.  The resulting layout mirrors the ``/srv`` tree
illustrated in ``README.md`` so that Codex and humans can navigate the sources
semantically.

Set ``GITHUB_TOKEN`` if any repositories require authentication.  See
``docs/environment_variables.md`` for details on authentication variables.
"""

import shutil
import subprocess
from pathlib import Path

from repo_config import REPOS


REPOS_DIR = Path("repos")
REPO_ORDER = ["fountainai", "kong-codex", "typesense-codex", "teatro"]


def run(cmd: list[str]) -> None:
    """Run ``cmd`` and raise if it fails."""
    subprocess.run(cmd, check=True)


def clone_repo(url: str, target: Path) -> None:
    """Clone ``url`` to ``target`` using a shallow clone."""
    run(["git", "clone", "--depth", "1", url, str(target)])


def copy_contents(src: Path, dest: Path) -> None:
    """Copy the working tree from ``src`` to ``dest`` ignoring ``.git``."""
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest, ignore=shutil.ignore_patterns(".git"))


def main() -> None:
    REPOS_DIR.mkdir(exist_ok=True)
    for name in REPO_ORDER:
        url = REPOS[name]
        tmp = REPOS_DIR / f"_{name}_tmp"
        clone_repo(url, tmp)
        copy_contents(tmp, REPOS_DIR / name)
        shutil.rmtree(tmp)

    run(["git", "add", str(REPOS_DIR)])
    run(["git", "commit", "-m", "Add initial copies of managed repositories"])


if __name__ == "__main__":
    main()

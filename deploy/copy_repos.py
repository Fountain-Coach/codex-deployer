"""Copy configured repositories into ``repos/`` as a monorepo snapshot.

This script clones each repository defined in :mod:`deploy.repo_config` and
copies its working tree (without ``.git``) into a ``repos/`` directory at the

root of ``codex-deployer``. The layout follows the repository order in
``deploy.repo_config.REPO_ORDER``, mirroring the ``/srv`` tree shown in
``README.md`` so that Codex and humans can navigate sources semantically.


Set ``GITHUB_TOKEN`` if any repositories require authentication.  See
``docs/environment_variables.md`` for details on authentication variables.
"""


import os

import shutil
import subprocess
from pathlib import Path

from repo_config import REPOS, REPO_ORDER


# Local directory that will mirror the `/srv` tree described in README.md.
REPOS_DIR = Path("repos")


def run(cmd: list[str]) -> None:
    """Run ``cmd`` and raise if it fails."""
    subprocess.run(cmd, check=True)


def clone_repo(url: str, target: Path) -> None:

    """Clone ``url`` to ``target`` using a shallow clone.

    If ``GITHUB_TOKEN`` is set, embed it in the clone URL to authenticate
    private repositories. The token is not logged.
    """
    token = os.environ.get("GITHUB_TOKEN")
    if token and url.startswith("https://"):
        auth_url = url.replace("https://", f"https://{token}@")
    else:
        auth_url = url
    run(["git", "clone", "--depth", "1", auth_url, str(target)])


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

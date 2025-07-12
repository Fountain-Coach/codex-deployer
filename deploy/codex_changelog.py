import os
# OPENAI_API_KEY is documented in docs/environment_variables.md
import subprocess
from datetime import datetime

try:
    import openai
except Exception:  # openai might not be installed
    openai = None


def generate_commit_message(repo_path: str, default: str) -> str:
    """Return a concise commit message summarizing staged changes."""
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key or openai is None:
        return default
    diff = subprocess.run(
        ["git", "-C", repo_path, "diff", "--staged"],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    if not diff.strip():
        return default
    openai.api_key = api_key
    prompt = (
        "Summarize the following git diff as a concise commit message. "
        "Use imperative mood and keep under 72 characters.\n\n" + diff
    )
    try:
        resp = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=50,
        )
        message = resp.choices[0].message["content"].strip()
        first_line = message.splitlines()[0]
        return first_line[:72]
    except Exception:
        return default


def append_changelog(repo_path: str, message: str) -> None:
    """Append the commit message to CHANGELOG.md in the repo."""
    changelog = os.path.join(repo_path, "CHANGELOG.md")
    ts = datetime.utcnow().isoformat()
    entry = f"- {ts} {message}\n"
    with open(changelog, "a") as fh:
        fh.write(entry)
    subprocess.run(["git", "-C", repo_path, "add", "CHANGELOG.md"], check=False)

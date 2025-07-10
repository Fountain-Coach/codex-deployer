import subprocess, os, time, datetime

from repo_config import REPOS, ALIASES

LOG_DIR = "/srv/deploy/logs"
FEEDBACK_DIR = "/srv/deploy/feedback"
LOG_FILE = os.path.join(LOG_DIR, "build.log")

def ensure_dirs():
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(FEEDBACK_DIR, exist_ok=True)

def timestamp():
    return datetime.datetime.now().isoformat()

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp()}] {msg}\n")

def push_logs_to_github():
    log_path = os.path.join(LOG_DIR, "build.log")
    latest_log_path = os.path.join("/srv/deploy", "logs", "latest.log")
    os.makedirs(os.path.dirname(latest_log_path), exist_ok=True)
    subprocess.run(["cp", log_path, latest_log_path])
    subprocess.run(["git", "-C", "/srv/deploy", "add", "logs/latest.log"])
    subprocess.run([
        "git",
        "-C",
        "/srv/deploy",
        "commit",
        "-m",
        f"Update build log: {timestamp()}",
    ])
    subprocess.run(["git", "-C", "/srv/deploy", "push"])

def pull_repos():
    for alias, url in REPOS.items():
        path = f"/srv/{alias}"
        canonical = ALIASES.get(alias, alias)
        if not os.path.exists(path):
            subprocess.run(["git", "clone", url, path])
            log(f"Cloned {alias} -> {canonical}")
        else:
            subprocess.run(["git", "-C", path, "pull"])
            log(f"Pulled latest {alias} -> {canonical}")

def build_swift():
    with open(LOG_FILE, "a") as f:
        f.write(f"\n[{timestamp()}] Starting swift build...\n")
        subprocess.run(["swift", "build"], cwd="/srv/fountainai", stdout=f, stderr=subprocess.STDOUT)

def commit_applied_patch(fname):
    patch_path = os.path.join(FEEDBACK_DIR, fname)
    new_name = f"applied-{fname}"
    new_path = os.path.join(FEEDBACK_DIR, new_name)
    os.rename(patch_path, new_path)
    subprocess.run(["git", "-C", "/srv/deploy", "add", f"feedback/{new_name}"])
    subprocess.run([
        "git",
        "-C",
        "/srv/deploy",
        "commit",
        "-m",
        f"Applied patch: {fname}",
    ])
    subprocess.run(["git", "-C", "/srv/deploy", "push"])

def apply_codex_feedback():
    for fname in os.listdir(FEEDBACK_DIR):
        if fname.endswith(".json"):
            log(f"Codex feedback detected: {fname}")
            subprocess.run(["bash", "/srv/deploy/commands/restart-services.sh"])
            commit_applied_patch(fname)

def loop():
    ensure_dirs()
    while True:
        log("=== New Cycle ===")
        pull_repos()
        build_swift()
        push_logs_to_github()
        apply_codex_feedback()
        time.sleep(60)

if __name__ == "__main__":
    loop()

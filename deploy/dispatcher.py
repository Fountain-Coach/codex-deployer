import subprocess, os, time, datetime

from repo_config import REPOS, ALIASES

LOG_FILE = "/srv/deploy/logs/build.log"
FEEDBACK_DIR = "/srv/deploy/feedback/"

def timestamp():
    return datetime.datetime.now().isoformat()

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp()}] {msg}\n")

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

def apply_codex_feedback():
    for fname in os.listdir(FEEDBACK_DIR):
        if fname.endswith(".json"):
            log(f"Codex feedback detected: {fname}")
            subprocess.run(["bash", "/srv/deploy/commands/restart-services.sh"])
            os.rename(FEEDBACK_DIR + fname, FEEDBACK_DIR + f".applied-{fname}")

def loop():
    while True:
        log("=== New Cycle ===")
        pull_repos()
        build_swift()
        apply_codex_feedback()
        time.sleep(60)

if __name__ == "__main__":
    loop()

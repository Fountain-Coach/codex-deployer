import subprocess, os, time, datetime

REPO_NAMES = ["fountainai", "kong-codex", "typesense-codex", "teatro", "teatro-playground"]
REPOS_DIR = "/srv/deploy/repos"

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


def build_swift():
    with open(LOG_FILE, "a") as f:
        f.write(f"\n[{timestamp()}] Starting swift build...\n")
        repo_path = os.path.join(REPOS_DIR, "fountainai")
        result = subprocess.run(
            ["swift", "build"],
            cwd=repo_path,
            stdout=f,
            stderr=subprocess.STDOUT,
        )
        if result.returncode != 0:
            f.write(
                f"[{timestamp()}] swift build failed with exit code {result.returncode}\n"
            )

def run_swift_tests():
    with open(LOG_FILE, "a") as f:
        f.write(f"\n[{timestamp()}] Starting swift test...\n")
        repo_path = os.path.join(REPOS_DIR, "fountainai")
        result = subprocess.run(
            ["swift", "test"],
            cwd=repo_path,
            stdout=f,
            stderr=subprocess.STDOUT,
        )
        if result.returncode != 0:
            f.write(
                f"[{timestamp()}] swift test failed with exit code {result.returncode}\n"
            )

def run_swift_executable(target="bootstrap-service"):
    with open(LOG_FILE, "a") as f:
        f.write(f"\n[{timestamp()}] Starting swift run {target}...\n")
        repo_path = os.path.join(REPOS_DIR, "fountainai")
        result = subprocess.run(
            ["swift", "run", target],
            cwd=repo_path,
            stdout=f,
            stderr=subprocess.STDOUT,
        )
        if result.returncode != 0:
            f.write(
                f"[{timestamp()}] swift run {target} exited with {result.returncode}\n"
            )

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
        apply_codex_feedback()
        build_swift()
        run_swift_tests()
        run_swift_executable()
        push_logs_to_github()
        time.sleep(60)

if __name__ == "__main__":
    loop()

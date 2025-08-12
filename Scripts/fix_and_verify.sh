#!/usr/bin/env bash
set -euo pipefail

echo "[info] Creating clang module cache directory..."
mkdir -p "$HOME/.cache/clang/ModuleCache"

echo "[info] Showing current ownership (optional)..."
ls -ld "$HOME/.cache" "$HOME/.cache/clang" "$HOME/.cache/clang/ModuleCache" 2>/dev/null || true

echo "[info] Ensuring cache is owned by current user (may prompt for sudo)..."
if [ "$(stat -f %Su "$HOME/.cache" 2>/dev/null || true)" != "$(whoami)" ]; then
  sudo chown -R "$(whoami)" "$HOME/.cache"
fi

echo "[info] Setting user read/write/execute on clang cache..."
chmod -R u+rwX "$HOME/.cache/clang" 2>/dev/null || true

echo "[info] Verifying Swift and Xcode toolchain..."
swift --version || { echo "[error] 'swift' not found in PATH"; exit 1; }
xcode-select -p || echo "[warn] xcode-select path not found; run 'xcode-select --install' if needed"

echo "[info] Building sps (release) -- this may take several minutes..."
cd "$(dirname "$0")/.." || exit 1
swift build -c release --package-path sps -v

echo "[info] If build succeeded, running full verify pipeline..."
FULL=1 bash Scripts/verify_pipeline.sh

echo "[info] Done."


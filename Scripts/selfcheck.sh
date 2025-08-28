#!/usr/bin/env bash
set -euo pipefail

echo "[selfcheck] swift build"
swift build

echo "[selfcheck] swift test --parallel"
swift test --parallel

echo "[selfcheck] OK"


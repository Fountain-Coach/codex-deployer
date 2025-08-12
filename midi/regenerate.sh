#!/usr/bin/env bash
# Recreate MIDI 2.0 models deterministically from specs using SPS.
set -euo pipefail
export LC_ALL=C
export LANG=C

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Ensure consistent timestamps are not embedded by downstream tools.
export SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-1711843200} # 2024-04-01

echo "[midi] Ingesting specs -> models matrix..."
"$REPO_ROOT/midi/ingest.sh"

echo "[midi] Parsing index fragments..."
( cd "$REPO_ROOT/midi" && swift run IndexParser )

echo "[midi] Building normalized model artifacts..."
"$REPO_ROOT/midi/build-models.sh"

echo "[midi] Done. Artifacts in midi/models"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

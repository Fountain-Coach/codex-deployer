#!/usr/bin/env bash
# Generate normalized machine-readable models from the SPS matrix.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$REPO_ROOT/midi/models"
MATRIX_JSON="$MODELS_DIR/matrix.json"
SLICE_SCRIPT="$REPO_ROOT/midi/slice-matrix.swift"
if [[ ! -f "$MATRIX_JSON" ]]; then
  echo "Matrix JSON not found at $MATRIX_JSON" >&2
  exit 1
fi
swift "$SLICE_SCRIPT" "$MATRIX_JSON" "$MODELS_DIR"
echo "Regenerated MIDI model slices."
# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

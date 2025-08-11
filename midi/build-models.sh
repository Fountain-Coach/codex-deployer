#!/usr/bin/env bash
# Generate normalized machine-readable models from the SPS matrix.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$REPO_ROOT/midi/models"
MATRIX_JSON="$MODELS_DIR/matrix.json"
if [[ ! -f "$MATRIX_JSON" ]]; then
  echo "Matrix JSON not found at $MATRIX_JSON" >&2
  exit 1
fi
jq '.messages // []' "$MATRIX_JSON" > "$MODELS_DIR/messages.json"
jq '.enums // []' "$MATRIX_JSON" > "$MODELS_DIR/enums.json"
jq '.bitfields // []' "$MATRIX_JSON" > "$MODELS_DIR/bitfields.json"
jq '.ranges // []' "$MATRIX_JSON" > "$MODELS_DIR/ranges.json"
echo "Wrote messages to $MODELS_DIR/messages.json"
echo "Wrote enums to $MODELS_DIR/enums.json"
echo "Wrote bitfields to $MODELS_DIR/bitfields.json"
echo "Wrote ranges to $MODELS_DIR/ranges.json"
# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

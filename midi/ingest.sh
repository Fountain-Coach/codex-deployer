#!/usr/bin/env bash
# Ingest MIDI 2.0 specification PDFs via the SPS pipeline.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPS_DIR="$REPO_ROOT/sps"
SPS_BIN="$SPS_DIR/.build/release/sps"
if [[ ! -x "$SPS_BIN" ]]; then
  swift build -c release --package-path "$SPS_DIR"
fi
SPECS_DIR="$REPO_ROOT/midi/specs"
MODELS_DIR="$REPO_ROOT/midi/models"
mkdir -p "$MODELS_DIR"
INDEX_JSON="$MODELS_DIR/index.json"
MATRIX_JSON="$MODELS_DIR/matrix.json"
shopt -s nullglob
PDFS=("$SPECS_DIR"/*.pdf)
if (( ${#PDFS[@]} == 0 )); then
  echo "No specification PDFs found in $SPECS_DIR" >&2
  exit 0
fi
"$SPS_BIN" scan "${PDFS[@]}" --out "$INDEX_JSON" --include-text --sha256
"$SPS_BIN" export-matrix "$INDEX_JSON" --out "$MATRIX_JSON" --validate
echo "Wrote index to $INDEX_JSON"
echo "Wrote matrix to $MATRIX_JSON"
# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

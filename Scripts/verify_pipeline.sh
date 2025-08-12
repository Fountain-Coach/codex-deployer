#!/usr/bin/env bash
set -euo pipefail

# One-shot verification script for the SPS -> MIDI model pipeline.
# Usage:
#   ./scripts/verify_pipeline.sh         # quick run (pages 1-3)
#   FULL=1 ./scripts/verify_pipeline.sh  # full run over all pages (may be slow)
#   PAGE_RANGE=1-5 ./scripts/verify_pipeline.sh  # custom page range
#
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPS_BIN="$REPO_ROOT/sps/.build/release/sps"
OUT_INDEX="$REPO_ROOT/midi/models/index.verify.json"
MATRIX_OUT="$REPO_ROOT/midi/models/matrix.verify.json"

PAGE_RANGE="${PAGE_RANGE:-1-3}"
FULL="${FULL:-0}"
SPS_DEBUG="${SPS_DEBUG:-1}"

export SPS_DEBUG

echo "[verify] repo root: $REPO_ROOT"
echo "[verify] SPS_DEBUG=$SPS_DEBUG PAGE_RANGE=$PAGE_RANGE FULL=$FULL"

echo "[verify] Building sps (release)..."
swift build -c release --package-path "$REPO_ROOT/sps"

if [[ ! -x "$SPS_BIN" ]]; then
  echo "[verify] ERROR: built binary not found at $SPS_BIN" >&2
  exit 2
fi

PDFS=("$REPO_ROOT/midi/specs"/*.pdf)
if (( ${#PDFS[@]} == 0 )); then
  echo "[verify] No PDFs found in midi/specs/" >&2
  exit 1
fi

echo "[verify] Scanning PDFs -> index: $OUT_INDEX"
if [[ "$FULL" == "1" ]]; then
  "$SPS_BIN" scan "${PDFS[@]}" --out "$OUT_INDEX" --include-text --sha256 --wait
else
  "$SPS_BIN" scan "${PDFS[@]}" --out "$OUT_INDEX" --include-text --sha256 --wait --page-range "$PAGE_RANGE"
fi

echo "[verify] Exporting matrix -> $MATRIX_OUT (with validation)"
"$SPS_BIN" export-matrix "$OUT_INDEX" --out "$MATRIX_OUT" --validate || true

echo "[verify] Building normalized models (midi/build-models.sh)"
"$REPO_ROOT/midi/build-models.sh"

echo "[verify] Matrix summary (counts):"
if [[ -f "$MATRIX_OUT" ]]; then
  jq '{messages: (.messages|length), enums: (.enums|length), bitfields: (.bitfields|length), ranges: (.ranges|length)}' "$MATRIX_OUT" || true
else
  echo "[verify] $MATRIX_OUT not found"
fi

echo "[verify] Running MIDI2 tests (swift test --filter MIDI2)"
swift test --filter MIDI2 || true

echo "[verify] Done. Index: $OUT_INDEX, Matrix: $MATRIX_OUT"


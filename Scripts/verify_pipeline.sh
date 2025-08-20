#!/usr/bin/env bash
set -euo pipefail

INDEX=$(mktemp)
trap 'rm -f "$INDEX"' EXIT

toolsmith-cli pdf-scan sps/Samples/extraction_sample.pdf > "$INDEX"
toolsmith-cli pdf-index-validate "$INDEX" >/dev/null
toolsmith-cli pdf-query "$INDEX" annotated 1 >/dev/null
toolsmith-cli pdf-export-matrix "$INDEX" >/dev/null

echo "[verify] Toolsmith PDF pipeline OK"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

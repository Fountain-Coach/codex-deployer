#!/usr/bin/env bash
set -euo pipefail

missing=0
tools=$(python3 - <<'PY'
import json
with open('tools.json') as f:
    data = json.load(f)
print(' '.join(data['tools'].keys()))
PY
)
for tool in $tools; do
  file="LICENSES/${tool}.txt"
  if [[ ! -f "$file" ]]; then
    echo "[license] Missing $file"
    missing=1
    continue
  fi
  if ! grep -q '^Source: ' "$file"; then
    echo "[license] Missing Source line in $file"
    missing=1
  fi
done

if [[ ! -f docs/licensing-matrix.md ]]; then
  echo "[license] Missing docs/licensing-matrix.md"
  missing=1
fi

if [[ $missing -ne 0 ]]; then
  echo "[license] verification failed" >&2
  exit 1
fi

echo "[license] all licenses verified"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

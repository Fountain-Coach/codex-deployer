#!/usr/bin/env bash
set -euo pipefail

echo "[check_no_codex] verifying FountainCodex imports"

if rg 'import\s+FountainCodex' --type swift --glob '!libs/FountainRuntime/Reexport.swift' >/dev/null; then
  echo "[check_no_codex] unexpected FountainCodex import(s) detected:"
  rg 'import\s+FountainCodex' --type swift --glob '!libs/FountainRuntime/Reexport.swift'
  exit 1
fi

echo "[check_no_codex] OK"

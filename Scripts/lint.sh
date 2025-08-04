#!/bin/bash
set -euo pipefail

TS=$(date +"%Y%m%d%H%M%S")
LOG_DIR="$(dirname "$0")/../logs"
LOG_FILE="$LOG_DIR/lint-$TS.log"
mkdir -p "$LOG_DIR"

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "swiftlint is not installed. Skipping lint." | tee "$LOG_FILE"
  printf "\n© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.\n" >> "$LOG_FILE"
  exit 0
fi

swiftlint lint --config "$(dirname "$0")/../.swiftlint.yml" "$@" | tee "$LOG_FILE"
printf "© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.\n" >> "$LOG_FILE"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

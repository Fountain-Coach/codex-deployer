#!/bin/bash
set -euo pipefail

# Timestamp used to differentiate successive log files.
TS=$(date +"%Y%m%d%H%M%S")
LOG_DIR="logs"
mkdir -p "$LOG_DIR" build

###############################################################################
# 1. Generate OpenAPI sources
###############################################################################
swift Scripts/generate-toolsmith-client.swift \
  2>&1 | tee "$LOG_DIR/openapi-$TS.log"

if ! git diff --quiet -- FountainAIToolsmith/Sources/ToolsmithAPI Sources/ToolServer; then
  git config --global user.email "ci@example.com"
  git config --global user.name "CI"
  git add FountainAIToolsmith/Sources/ToolsmithAPI Sources/ToolServer
  git commit -m "chore: regenerate OpenAPI client" || true
fi

###############################################################################
# 2. Build sandbox image and verify checksums
###############################################################################
BUILD_SANDBOX=${BUILD_SANDBOX:-1}
if [[ "$(uname)" == "Linux" ]]; then
  if [[ "$BUILD_SANDBOX" == "1" ]]; then
    OUTPUT_DIR=build Scripts/build-sandbox-image.sh \
      2>&1 | tee "$LOG_DIR/sandbox-$TS.log"
  fi

  if [[ -f build/tools.json ]]; then
    expected=$(jq -r '.image.sha256' tools.json)
    actual=$(jq -r '.image.sha256' build/tools.json)
    if [[ "$expected" != "$actual" ]]; then
      echo "Checksum mismatch: $expected != $actual" >&2
      exit 1
    fi
  else
    echo "Sandbox manifest build/tools.json missing" >&2
    exit 1
  fi
fi

###############################################################################
# 3. Build package and run tests
###############################################################################
swift build -c release -Xswiftc -O -Xswiftc -warnings-as-errors \
  2>&1 | tee "$LOG_DIR/build-$TS.log"

swift test -c release --enable-code-coverage \
  2>&1 | tee "$LOG_DIR/test-$TS.log"

if [[ -d sps ]]; then
  pushd sps >/dev/null
  swift test --enable-code-coverage \
    2>&1 | tee "../$LOG_DIR/sps-test-$TS.log"
  popd >/dev/null
fi

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

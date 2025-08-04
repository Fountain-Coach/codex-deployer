#!/bin/bash
set -euo pipefail

# Timestamp used to differentiate successive log files.
TS=$(date +"%Y%m%d%H%M%S")

# Build the package in release mode while treating warnings as errors.
# Output is tee'd into a log under the `logs` directory for later inspection.
swift build -c release -Xswiftc -O -Xswiftc -warnings-as-errors \
  2>&1 | tee "logs/build-$TS.log"

# Execute the test suite with code coverage enabled and capture the results.
swift test -c release --enable-code-coverage \
  2>&1 | tee "logs/test-$TS.log"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

#!/bin/bash
set -euo pipefail
TS=$(date +"%Y%m%d%H%M%S")
swift build -c release -Xswiftc -O -Xswiftc -warnings-as-errors 2>&1 | tee "logs/build-$TS.log"
swift test -c release --enable-code-coverage 2>&1 | tee "logs/test-$TS.log"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

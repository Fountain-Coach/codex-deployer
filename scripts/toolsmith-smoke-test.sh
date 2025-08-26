#!/usr/bin/env bash
set -euo pipefail

swift test --package-path toolsmith --filter OrchestratorRoundTripTests

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

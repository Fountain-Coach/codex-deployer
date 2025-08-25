#!/usr/bin/env bash
set -euo pipefail

echo "This project expects generated sources under Sources/openapi/Generated."
echo "Populate these from your API definitions or toolsmith pipeline."
echo

echo "Suggested layout:"
echo "  Sources/openapi/Generated/Client/<service>/{APIClient.swift,APIRequest.swift,Models.swift,Requests/*}"
echo "  Sources/openapi/Generated/Server/Shared/*.swift"
echo "  Sources/openapi/Generated/Server/<service>/*.swift"
echo

echo "This script is a placeholder. Wire it to your generator when available."

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

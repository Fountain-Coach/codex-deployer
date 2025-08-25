#!/usr/bin/env bash
set -euo pipefail

echo "This project expects generated sources under Sources/FountainOps/Generated."
echo "Populate these from your API definitions or toolsmith pipeline."
echo
echo "Suggested layout:"
echo "  Sources/FountainOps/Generated/Client/<service>/{APIClient.swift,APIRequest.swift,Models.swift,Requests/*}"
echo "  Sources/FountainOps/Generated/Server/Shared/*.swift"
echo "  Sources/FountainOps/Generated/Server/<service>/*.swift"
echo
echo "This script is a placeholder. Wire it to your generator when available."


#!/usr/bin/env bash
set -euo pipefail

SPEC="FountainAi/openAPI/typesense.yml"
SERVICE="typesense"
OUT_DIR="Generated/$SERVICE"

rm -rf "$OUT_DIR"

swift run clientgen-service --input "$SPEC" --output "$OUT_DIR"

mkdir -p "Generated/Client/$SERVICE" "Generated/Server/$SERVICE"
cp -r "$OUT_DIR/Client/." "Generated/Client/$SERVICE/"
cp -r "$OUT_DIR/Server/." "Generated/Server/$SERVICE/"
if [ -f "$OUT_DIR/Models.swift" ]; then
    cp "$OUT_DIR/Models.swift" "Generated/Client/$SERVICE/Models.swift"
    cp "$OUT_DIR/Models.swift" "Generated/Server/$SERVICE/Models.swift"
fi
rm -rf "$OUT_DIR"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

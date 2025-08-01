#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$PACKAGE_DIR/../.." && pwd)"

SPEC_PATH="$ROOT_DIR/repos/fountainai/Sources/FountainOps/FountainAi/openAPI/typesense.yml"
OUTPUT_DIR="$PACKAGE_DIR/Sources/TypesenseClient"

rm -rf "$OUTPUT_DIR"

TMP_DIR="$(mktemp -d)"

pushd "$ROOT_DIR/repos/fountainai" >/dev/null
swift run generator --input "$SPEC_PATH" --output "$TMP_DIR"
popd >/dev/null

mkdir -p "$PACKAGE_DIR/Sources"
mv "$TMP_DIR/Client" "$OUTPUT_DIR"
rm -rf "$TMP_DIR"

echo "Swift client generated in $OUTPUT_DIR"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

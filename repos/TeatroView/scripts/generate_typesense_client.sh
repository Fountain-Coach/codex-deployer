#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$PACKAGE_DIR/../.." && pwd)"

SPEC_PATH="$ROOT_DIR/repos/typesense-codex/openapi/openapi.yml"
OUTPUT_DIR="$PACKAGE_DIR/Sources/TypesenseClient"

rm -rf "$OUTPUT_DIR"

TMP_DIR="$(mktemp -d)"
GENERATOR_BIN="${GENERATOR_BIN:-openapi-generator-cli}"

"$GENERATOR_BIN" generate \
  -i "$SPEC_PATH" \
  -g swift6 \
  -o "$TMP_DIR" \
  --package-name TypesenseClient \
  --additional-properties=projectName=TypesenseClient,useSPMFileStructure=true

mkdir -p "$PACKAGE_DIR/Sources"
mv "$TMP_DIR/Sources/TypesenseClient" "$OUTPUT_DIR"
rm -rf "$TMP_DIR"

echo "Swift client generated in $OUTPUT_DIR"

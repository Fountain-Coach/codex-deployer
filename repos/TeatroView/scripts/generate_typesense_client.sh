#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$PACKAGE_DIR/../.." && pwd)"

GENERATOR_DIR="$ROOT_DIR/repos/fountainai"
SPEC_PATH="$ROOT_DIR/repos/typesense-codex/openapi/openapi.yml"
OUTPUT_DIR="$PACKAGE_DIR/Sources/TypesenseClient"

# Build the generator from the fountainai repository
swift build -c release --product generator --package-path "$GENERATOR_DIR"

# Remove any previously generated sources
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Generate the client using the custom Swift 6 generator
TMP_DIR="$(mktemp -d)"
swift run --package-path "$GENERATOR_DIR" generator --input "$SPEC_PATH" --output "$TMP_DIR"
cp -r "$TMP_DIR/Client/." "$OUTPUT_DIR/"
rm -rf "$TMP_DIR"

#!/usr/bin/env bash
set -euo pipefail

# Pre-deployment verification for container images and OpenAPI specs.
# Usage: scripts/predeploy.sh <image-ref>
# Requires COSIGN_PUBLIC_KEY to point to the verifying key.
# Tools: openapi-curator-cli, cosign, grype, syft.

IMAGE="${1:-}"
if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image-ref>" >&2
  exit 64
fi

# Run OpenAPI curation in review mode and archive results.
CURATOR_SPEC="${CURATOR_SPEC:-openapi}"
ARTIFACT_DIR="${ARTIFACT_DIR:-artifacts}"
CURATION_DIR="$ARTIFACT_DIR/openapi-curation"
mkdir -p "$CURATION_DIR"

echo "[predeploy] Running OpenAPI curator review on $CURATOR_SPEC"
openapi-curator-cli review "$CURATOR_SPEC" \
  --output "$CURATION_DIR/curated.yaml" \
  --report "$CURATION_DIR/report.json"

if [[ ! -s "$CURATION_DIR/curated.yaml" || ! -s "$CURATION_DIR/report.json" ]]; then
  echo "[predeploy] Missing curation artifacts" >&2
  exit 1
fi

COSIGN_KEY="${COSIGN_PUBLIC_KEY:-docs/security/cosign.pub}"
if [[ ! -f "$COSIGN_KEY" ]]; then
  echo "[predeploy] Public key not found: $COSIGN_KEY" >&2
  exit 1
fi

echo "[predeploy] Verifying signature for $IMAGE"
cosign verify --key "$COSIGN_KEY" "$IMAGE"

echo "[predeploy] Scanning for vulnerabilities"
grype --fail-on high "$IMAGE"

echo "[predeploy] Generating SBOM"
SBOM_DIR="${SBOM_DIR:-logs}"
mkdir -p "$SBOM_DIR"
SBOM_FILE="$SBOM_DIR/sbom-$(echo "$IMAGE" | tr '/:' '_').json"
syft "$IMAGE" -o json > "$SBOM_FILE"

echo "[predeploy] SBOM saved to $SBOM_FILE"

echo "[predeploy] All checks passed"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

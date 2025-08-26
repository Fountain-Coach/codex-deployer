#!/usr/bin/env bash
set -euo pipefail

# Pre-deployment verification for container images.
# Usage: scripts/predeploy.sh <image-ref>
# Requires COSIGN_PUBLIC_KEY to point to the verifying key.
# Tools: cosign, grype, syft.

IMAGE="${1:-}"
if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image-ref>" >&2
  exit 64
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

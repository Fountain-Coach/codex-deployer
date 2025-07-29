#!/usr/bin/env bash
set -euo pipefail

CERTBOT=${CERTBOT:-certbot}
DOMAIN=${GATEWAY_DOMAIN:-gateway.fountain.coach}
EMAIL=${LE_EMAIL:-admin@fountain.coach}
DATA_DIR=${CERT_DIR:-/var/lib/gateway/certs}

mkdir -p "$DATA_DIR"

exec $CERTBOT certonly \
  --non-interactive --standalone \
  --agree-tos --email "$EMAIL" \
  --config-dir "$DATA_DIR" \
  --logs-dir "$DATA_DIR" \
  --work-dir "$DATA_DIR" \
  -d "$DOMAIN"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

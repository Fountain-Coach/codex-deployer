#!/usr/bin/env bash
# Acquires or renews TLS certificates using certbot with DNS-01 challenge via API.
# Environment variables allow overriding domain, email, and storage paths.
set -euo pipefail

CERTBOT=${CERTBOT:-certbot}
DOMAIN=${GATEWAY_DOMAIN:-gateway.fountain.coach}
EMAIL=${LE_EMAIL:-admin@fountain.coach}
DATA_DIR=${CERT_DIR:-/var/lib/gateway/certs}
AUTH_HOOK=${AUTH_HOOK:-$(dirname "$0")/dns-api-hook.sh auth}
CLEANUP_HOOK=${CLEANUP_HOOK:-$(dirname "$0")/dns-api-hook.sh cleanup}

mkdir -p "$DATA_DIR"

exec $CERTBOT certonly \
  --non-interactive --manual --preferred-challenges dns \
  --manual-auth-hook "$AUTH_HOOK" \
  --manual-cleanup-hook "$CLEANUP_HOOK" \
  --agree-tos --email "$EMAIL" \
  --config-dir "$DATA_DIR" \
  --logs-dir "$DATA_DIR" \
  --work-dir "$DATA_DIR" \
  -d "$DOMAIN"

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

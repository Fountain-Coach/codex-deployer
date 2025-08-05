#!/usr/bin/env bash
# Delegates internal.fountain.coach to internal nameservers via Hetzner DNS API.
# Requires HETZNER_API_TOKEN and HETZNER_ZONE_ID environment variables.
set -euo pipefail

: "${HETZNER_API_TOKEN:?HETZNER_API_TOKEN required}"
: "${HETZNER_ZONE_ID:?HETZNER_ZONE_ID required}"

SUBDOMAIN=${SUBDOMAIN:-internal}
NS1=${NS1:-ns1.internal.fountain.coach}
NS2=${NS2:-ns2.internal.fountain.coach}
API="https://dns.hetzner.com/api/v1"

for ns in "$NS1" "$NS2"; do
  curl -sS -X POST "$API/records" \
    -H "Auth-API-Token: $HETZNER_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"zone_id\":\"$HETZNER_ZONE_ID\",\"type\":\"NS\",\"name\":\"$SUBDOMAIN\",\"value\":\"$ns\",\"ttl\":86400}" \
    >/dev/null
  echo "Delegated $SUBDOMAIN.fountain.coach to $ns"
done

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

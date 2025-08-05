#!/usr/bin/env bash
# Certbot hook script to manage DNS-01 challenge records via internal DNS API.
# Usage: dns-api-hook.sh <auth|cleanup>
set -euo pipefail

PHASE=${1:-}
API_URL=${DNS_API:-http://dns.fountain.coach/api/v1}
ZONE=${DNS_ZONE:-internal.fountain.coach}
TMPFILE="/tmp/acme-$CERTBOT_DOMAIN.txt"

case "$PHASE" in
  auth)
    RESPONSE=$(curl -sS -X POST "$API_URL/zones/$ZONE/records" \
      -H 'Content-Type: application/json' \
      -d "{\"name\":\"_acme-challenge.$CERTBOT_DOMAIN\",\"type\":\"TXT\",\"value\":\"$CERTBOT_VALIDATION\"}")
    echo "$RESPONSE" | python3 -c 'import sys,json; print(json.load(sys.stdin)["id"])' > "$TMPFILE"
    ;;
  cleanup)
    if [ -f "$TMPFILE" ]; then
      RECORD_ID=$(cat "$TMPFILE")
      curl -sS -X DELETE "$API_URL/zones/$ZONE/records/$RECORD_ID"
      rm -f "$TMPFILE"
    fi
    ;;
  *)
    echo "Unknown phase: $PHASE" >&2
    exit 1
    ;;
 esac

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

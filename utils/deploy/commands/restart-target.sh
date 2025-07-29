#!/bin/bash
# Restart service named by first argument. Falls back to fountainai.
SERVICE="$1"
if [ -z "$SERVICE" ]; then
  echo "No service specified" >&2
  exit 1
fi
systemctl restart "$SERVICE" 2>/dev/null || systemctl restart fountainai

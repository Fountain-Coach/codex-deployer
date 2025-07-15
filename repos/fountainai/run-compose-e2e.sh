#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
COMPOSE_FILE="$SCRIPT_DIR/Docs/Compose/function-caller-tools.yml"

cd "$SCRIPT_DIR"

docker compose -f "$COMPOSE_FILE" build

docker compose -f "$COMPOSE_FILE" up -d
trap 'docker compose -f "$COMPOSE_FILE" down -v' EXIT

# wait for function caller to be up
for i in {1..30}; do
  if curl -s http://localhost:8088/functions | grep -q "\["; then
    break
  fi
  sleep 2
done

# register a function that lists tools via tools-factory
curl -s -X POST http://localhost:8087/tools/register \
  -H 'Content-Type: application/json' \
  -d '[{"function_id":"list","name":"list","description":"list","http_method":"GET","http_path":"http://tools-factory:8080/tools"}]'

# invoke the function via Function Caller
resp=$(curl -s -X POST http://localhost:8088/functions/list/invoke -H 'Content-Type: application/json' -d '{}')

echo "Response: $resp"
if echo "$resp" | grep -q "functions"; then
  echo "Compose integration workflow succeeded"
else
  echo "Unexpected response from function caller" >&2
  exit 1
fi

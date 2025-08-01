#!/usr/bin/env python3
"""Create required Typesense collections for FountainAI services."""

import os
import json
import requests

TYPESENSE_URL = os.environ.get("TYPESENSE_URL")
API_KEY = os.environ.get("TYPESENSE_API_KEY", "")

if not TYPESENSE_URL:
    raise SystemExit("TYPESENSE_URL not set")

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), "../schemas/functions.schema.json")
with open(SCHEMA_PATH) as f:
    schema = json.load(f)

headers = {"X-API-Key": API_KEY, "Content-Type": "application/json"}
resp = requests.post(f"{TYPESENSE_URL.rstrip('/')}/collections", headers=headers, json=schema)
if resp.status_code not in (200, 201):
    raise SystemExit(f"failed to create collection: {resp.status_code} {resp.text}")
print("Created collection", schema["name"])

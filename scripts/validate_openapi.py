#!/usr/bin/env python3
"""Validate OpenAPI specs by ensuring they parse as YAML."""
import sys
import pathlib
import yaml

def main() -> int:
    root = pathlib.Path(__file__).resolve().parents[1] / "openapi"
    ok = True
    for spec in sorted(root.rglob("*.yml")):
        text = spec.read_text().strip().splitlines()
        if text and text[-1].startswith("©"):
            text = text[:-1]
        try:
            yaml.safe_load("\n".join(text))
            print(f"{spec}: ok")
        except Exception as e:
            ok = False
            print(f"{spec}: error {e}")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

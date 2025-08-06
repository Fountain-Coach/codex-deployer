#!/usr/bin/env python3
"""Audit OpenAPI operationIds against server code.

Scans OpenAPI spec files under Sources/FountainOps/FountainAi/openAPI
and checks whether each operationId appears somewhere in the source
code tree. Reports missing handlers per spec file.
"""
import subprocess
from pathlib import Path
import sys

SPEC_ROOT = Path("Sources/FountainOps/FountainAi/openAPI")
CODE_ROOT = Path("Sources")


def collect_operation_ids(spec_path: Path):
    ids = []
    with spec_path.open() as f:
        for line in f:
            line = line.strip()
            if line.startswith("operationId:"):
                ids.append(line.split("operationId:", 1)[1].strip())
    return ids


def opid_in_code(opid: str) -> bool:
    result = subprocess.run(
        [
            "rg",
            "-l",
            opid,
            str(CODE_ROOT),
            "--glob",
            "!**/openAPI/**",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    return bool(result.stdout.strip())


def main():
    exit_code = 0
    for spec in sorted(SPEC_ROOT.rglob("*.yml")):
        missing = [op for op in collect_operation_ids(spec) if not opid_in_code(op)]
        if missing:
            print(f"{spec}: missing handlers for {', '.join(missing)}")
            exit_code = 1
        else:
            print(f"{spec}: all operations mapped")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

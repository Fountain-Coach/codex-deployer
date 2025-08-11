# SPS Matrix Migration Notes

## v2 Matrix Schema

- Added `schemaVersion` to exported matrices.
- Optional `bitfields`, `ranges`, and `enums` sections supported via CLI flags.
- Default export remains compatible with prior versions.

Upgrade steps:
1. Bump any consumers expecting matrix v1 to handle `schemaVersion: "2.0"`.
2. Use new CLI flags (`--bitfields`, `--ranges`, `--enums`) when richer metadata is desired.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

# Zone Delegation

The `fountain.coach` domain is registered in Route53, while DNS records are managed through Hetzner's DNS API.

To delegate `internal.fountain.coach` to self-hosted DNS servers:

1. Export `HETZNER_API_TOKEN` and `HETZNER_ZONE_ID` for the parent `fountain.coach` zone.
2. Run `Scripts/delegate-internal-zone.sh` to create `NS` records pointing at your internal nameservers.
3. Verify delegation with `dig NS internal.fountain.coach`.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

# Environment Variables

The publishing service and DNS clients rely on the following variables:

| Variable | Default | Purpose |
|---------|---------|---------|
| `DNS_PROVIDER` | `hetzner` | Selects the DNS implementation to use. |
| `HETZNER_API_TOKEN` | _(none)_ | API token for Hetzner DNS requests. |
| `ROUTE53_ACCESS_KEY` | _(none)_ | AWS key for Route 53 (not yet used). |
| `ROUTE53_SECRET_KEY` | _(none)_ | AWS secret key for Route 53. |

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

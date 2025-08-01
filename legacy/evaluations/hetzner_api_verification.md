# Hetzner API Verification

The Hetzner DNS API base endpoints were checked using cURL to confirm availability. Requests without an API token return `401 Unauthorized` as expected.

Example response for `/api/v1/zones`:

```bash
$ curl -i https://dns.hetzner.com/api/v1/zones
HTTP/1.1 401 Unauthorized
{"message":"No API key found in request"}
```

This matches the paths defined in `Hetzner-DNS/hetzner_dns_openapi.yaml`.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

# Gateway Routing Usage

## Route Creation
Create a proxy route by POSTing JSON to `/routes`:

```bash
curl -X POST http://localhost:8080/routes \
  -H "Content-Type: application/json" \
  -d '{"id":"r1","path":"/api","target":"http://upstream/api","methods":["GET"],"proxyEnabled":true}'
```

## Prefix Matching
When `proxyEnabled` is `true`, requests with a matching prefix are forwarded to the target. The route above sends `/api/users` to `http://upstream/api/users`:

```bash
curl http://localhost:8080/api/users
```

## Header Forwarding
Response headers from the upstream are preserved. If the upstream includes `X-Upstream: yes`, the client receives the same header:

```bash
curl -i http://localhost:8080/api/status
```

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

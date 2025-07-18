# 🧠 kong-codex

Codex-managed configuration for the Kong API gateway. This repository includes a
`docker-compose.yml` setup that launches Kong in db-less mode with a
Typesense instance used by FountainAI.

`TYPESENSE_URL` and `TYPESENSE_API_KEY` must be exported in your environment so
that other services can discover the Typesense endpoint. See
[docs/environment_variables.md](../../docs/environment_variables.md) for details
on these variables.

## Quick start

1. Create a `.env` file with `TYPESENSE_API_KEY` set to your desired admin key.
2. (Optional) set `TYPESENSE_URL`; the compose file defaults to
   `http://localhost:8108`.
3. Start the stack:

```bash
docker compose up -d
```

Kong's admin API will be available on `http://localhost:8001` and the proxy
listens on `http://localhost:8000`. Typesense is reachable at `${TYPESENSE_URL}`.

```
```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```

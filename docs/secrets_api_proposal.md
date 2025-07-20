# Secrets API Injection Proposal

This document outlines an alternative to using `dispatcher.env` and other `.env` files. Instead of loading secrets from disk, the dispatcher would retrieve them at startup via a secure API call to a service under our control.

## Motivation

Storing long‑lived secrets on disk increases the risk of exposure. Fetching them on demand keeps credentials ephemeral and simplifies revocation. This design is particularly useful for deployments where systemd units or Docker containers may be rebuilt frequently.

## Proposed Design

1. **Bootstrap Credentials** – The dispatcher starts with only two environment variables:
   - `SECRETS_API_URL` – Endpoint of the secret management service.
   - `SECRETS_API_TOKEN` – Authentication token used to call the API.
2. **API Call at Startup** – On launch, the dispatcher calls `SECRETS_API_URL` with `SECRETS_API_TOKEN` to retrieve the full set of required environment variables.
3. **In‑Memory Injection** – The service returns JSON key/value pairs. These values are exported in memory so the dispatcher process gains access without writing to disk.
4. **Runtime Usage** – The dispatcher continues exactly as documented in [environment_variables.md](environment_variables.md), but secrets originate from the API rather than `dispatcher.env`.

## Benefits

- **Centralized Revocation** – Rotating a secret requires only updating the API, not every server.
- **Reduced Disk Footprint** – Secrets never touch the filesystem, lowering the risk of accidental commits or backups.
- **Auditable Access** – The secret service can log which machines request which credentials.

## Considerations

- **Network Availability** – The dispatcher must reach the secret service during startup. Consider a retry loop or cached fallback for resilience.
- **Service Security** – The API should use TLS and validate `SECRETS_API_TOKEN`. Short‑lived tokens or client certificates are recommended.
- **Local Development** – Developers can still use `dispatcher.env` as a fallback when the secret service is unavailable.

## Next Steps

Implementing this approach would require extending the dispatcher to perform the API call and parse the response before continuing with the build loop. See [environment_variables.md](environment_variables.md) for the complete list of variables that would be supplied by the secret service.



````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````


# Swift API Gateway Implementation Overview

This document outlines the initial code structure for the Swift-based API gateway and describes the certificate management subsystem that automatically retrieves and renews TLS certificates from Let's Encrypt.

## 1. Project Layout
- `gateway-server`: SPM target hosting the HTTP server built with SwiftNIO and the generated handlers.
- `Configuration/`: YAML files describing routes, rate limits and TLS settings committed to the repo.
- `Scripts/renew-certs.sh`: small helper invoked by a timer to renew certificates via `certbot` or another ACME client.
- `Sources/GatewayApp/`: entry point bootstrapping NIO, loading configuration and starting the server with HTTPS enabled.

## 2. Certificate Management
The gateway must present valid HTTPS certificates at all times. We rely on Let's Encrypt for issuance and renewal.
1. On first launch, `renew-certs.sh` requests a certificate for the gateway's domain using the ACME HTTP challenge.
2. The script stores the resulting files in a shared directory mounted into the Docker container.
3. A Swift task monitors certificate expiry and invokes the script periodically (e.g. via `DispatchSourceTimer`).
4. If renewal succeeds, the gateway reloads its TLS configuration without downtime.

## 3. Next Steps Toward a Kong-Like Gateway
- Add middleware for authentication, rate limiting and request logging based on the configuration files.
- Expose health and metrics endpoints defined in the OpenAPI spec.
- Implement plugin-style hooks so future features (like request transformations) mirror Kong's extensibility model.
- Document how to integrate other services using the generated Typesense client.

These steps follow the common patterns of gateways modelled after Kong while keeping the implementation fully Swift.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

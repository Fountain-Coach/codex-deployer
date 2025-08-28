# RoleGuard Plugin Configuration

The gateway can enforce role-based access rules via the built-in `RoleGuardPlugin`.

- Location: `apps/GatewayServer/GatewayApp/RoleGuardPlugin.swift`
- Load rules from YAML at `Configuration/roleguard.yml` or path in env `ROLE_GUARD_PATH`.

Example `Configuration/roleguard.yml`:

```
rules:
  "/awareness":
    roles: ["admin", "ops"]
    scopes: ["awareness.read"]
  "/bootstrap": "admin"  # string still supported (shorthand for roles: ["admin"])
```

- Keys are path prefixes; the longest matching prefix wins.
- Values are required roles; the plugin validates a bearer token in `Authorization: Bearer <JWT>` using the `CredentialStoreValidator`.
- 401 when missing/invalid token, 403 when role mismatch.

Generating test tokens

```
// Use gateway's CredentialStore to generate a JWT
env GATEWAY_JWT_SECRET=mysecret swift run gateway-server # server reads secret
```

Within a Swift context (tests or REPL):

```
let store = CredentialStore()
let admin = try store.signJWT(subject: "client", expiresAt: Date().addingTimeInterval(3600), role: "admin")
```

Now call gateway endpoints with:

```
curl -H "Authorization: Bearer $admin" http://localhost:8080/awareness/health
```

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

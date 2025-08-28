# RoleGuard Plugin Configuration

The gateway can enforce role-based access rules via the built-in `RoleGuardPlugin`.

- Location: `apps/GatewayServer/GatewayApp/RoleGuardPlugin.swift`
- Load rules from YAML at `Configuration/roleguard.yml` or path in env `ROLE_GUARD_PATH`.

Example `Configuration/roleguard.yml`:

```
rules:
  "/awareness":
    roles: ["admin", "ops"]
    scopes: ["awareness.read", "awareness.write"]
    scopes_mode: all   # require all scopes; omit or set to "any" to allow any one
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


Advanced examples

```
rules:
  "/awareness":
    roles: ["admin", "ops"]
    scopes: ["awareness.read", "awareness.write"]
    scopes_mode: all     # require both scopes
    methods: ["POST"]   # only apply to POSTs
  "/awareness/experimental":
    deny: true           # deny this subtree regardless of token
```


### Method-level deny

To deny specific methods on a path while allowing others, use `methods` with `deny: true`:

```
rules:
  "/awareness":
    deny: true
    methods: ["POST"]      # deny POSTs to /awareness and subpaths
```

GETs to `/awareness` still pass; POSTs return 403 regardless of token.

### Runtime management

The gateway exposes simple management endpoints to inspect and reload rules at runtime:

- `GET /roleguard` — returns the current rules as JSON. Requires an admin token.
- `POST /roleguard/reload` — reloads from `ROLE_GUARD_PATH` (or `Configuration/roleguard.yml`). Requires an admin token.
  - 204 when reload applied, 304 when no reload performed (e.g., file missing or unchanged).

Authorization: both endpoints require `Authorization: Bearer <JWT>` where the token has role `admin` (or includes an `admin` scope). They are intended for operators and should also be protected via network policy.

# Code Reference

*Links to API and inline docs.*

This placeholder collects API documentation derived from the source files.
Inline comments in both Python and Swift explain how the system works and how
it consumes the variables listed in [../environment_variables.md](../environment_variables.md).

## Python Modules

- [`deploy/dispatcher_v2.py`](../../deploy/dispatcher_v2.py) – main deployment loop
- [`analyze_swift_log.py`](../../analyze_swift_log.py) – build log analyzer

View the dispatcher API with:

```bash
pydoc deploy.dispatcher_v2
```

## Swift Packages

Generated services live under `repos/fountainai`. Documentation will be produced
with `swift package generate-documentation` once the build pipeline is enabled.



````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````


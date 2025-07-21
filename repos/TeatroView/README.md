# TeatroView – Typesense GUI

TeatroView is an experimental GUI for [Typesense](https://typesense.org) built with the [Teatro](../teatro) view engine. It demonstrates how Teatro renders SwiftUI scenes while providing a simple interface to manage and search a Typesense instance.

## Build and Run

Make sure the following environment variables are set so the app can reach your server:

| Variable | Purpose |
|----------|---------|
| `TYPESENSE_URL` | Base URL for a running Typesense instance |
| `TYPESENSE_API_KEY` | API key used for requests |

```
export TYPESENSE_URL=http://localhost:8108
export TYPESENSE_API_KEY=xyz
swift run TeatroView
```

The app builds with Swift Package Manager. Open the package in Xcode for SwiftUI previews or run from the command line as shown above.

### Dependency Layout

`Package.swift` expects the [Teatro](../teatro) package to be present one directory up at `../teatro`. If you cloned this project by itself, clone the Teatro repository next to `TeatroView`:

```bash
git clone https://github.com/fountain-coach/teatro ../teatro
```

Keeping this path intact ensures Swift Package Manager can resolve the `Teatro` product.

## Contributing

This project lives in the `TeatroView` directory of the `codex-deployer` monorepo. Issues and pull requests are welcome. Please keep the README updated if you change build steps or environment variables. Refer to `docs/environment_variables.md` for the full list of variables used across the project.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

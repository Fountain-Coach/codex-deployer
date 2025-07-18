# Architecture Overview

*Map of components and key features.*

For a gentle introduction see [Introduction to Codex-Deployer](introduction.md).

## Directory Layout

```text
[ GitHub ]
    ▲
    | (Codex pulls the self-contained repo)
    ▼
[ VPS ]
    /srv/deploy/
    ├── repos/               # service sources
    ├── deploy/              # dispatcher_v2.py
    ├── logs/                # build and test output
    ├── feedback/            # semantic patch proposals
    └── commands/            # optional admin scripts
```

### Components
- **repos/** – FountainAI, Kong, Typesense and Teatro repositories
- **dispatcher_v2.py** – daemonized loop that builds and tests services
- **logs/** – history of `swift build` and `swift test` output
- **feedback/** – JSON files describing code patches and commands
- **commands/** – optional scripts triggered by feedback entries

## Key Features


| Capability | Description |
|------------|-------------|
| ✅ Git-native | Codex pulls from `main` and reads current state |
| ✅ Swift compiler integration | Full `swift build`, `swift test` and `swift run` output is captured |
| ✅ Runs entirely on your VPS | No external runners are required |
| ✅ Semantic feedback loop | Codex writes JSON to `/feedback/`, patches are applied |
| ✅ Daemon architecture | One Python loop drives the whole system |
| ✅ Multi-repo awareness | Includes FountainAI, Kong, Typesense and Teatro sources in one repository |
| ✅ Developer-agnostic | Works whether code was committed by a human or Codex |
| ✅ GitHub sync | Build logs and applied patches automatically pushed |
| ✅ Log rotation | Each cycle writes `build-YYYYMMDD-HHMMSS.log` for history |
| ✅ Platform-aware compilation | Uses `xcrun` on macOS, open source Swift elsewhere |
| ✅ Codex-generated commits | Set `OPENAI_API_KEY` for semantic commit messages |
| ✅ Custom OpenAI endpoint | Set `OPENAI_API_BASE` to override the API URL. See [environment_variables.md](../environment_variables.md) |
| ✅ Docker builds & e2e tests | Set `DISPATCHER_BUILD_DOCKER=1` and `DISPATCHER_RUN_E2E=1` for container workflows |

For implementation details see [dispatcher_v2.md](../dispatcher_v2.md).


```



```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```

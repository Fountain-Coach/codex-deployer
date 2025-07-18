# Architecture Overview

This page expands on the overall structure and capabilities of **Codex-Deployer**. It collects information that was previously spread across the main README.

## System Design

```
[ GitHub ]
    ▲
    |   (codex pulls the self-contained repo)
    ▼
[ VPS: FountainAI Node ]
    /srv/deploy/
    ├── repos/
    │   ├── fountainai/       ← Swift + Python services
    │   ├── kong-codex/       ← Gateway config + local Typesense
    │   ├── typesense-codex/  ← Schema definitions + indexing logic
    │   └── teatro/           ← Teatro view engine
    ├── deploy/
    │   └── dispatcher_v2.py   ← Daemonized build + feedback loop
    ├── logs/
    │    └── build.log  ← Swift compiler output
    ├── feedback/
    │    └── codex-001.json  ← Structured GPT feedback
    └── commands/
         ├── restart-services.sh (optional legacy script)
         └── restart-target.sh  ← restart a specific service
```

## Feature Highlights

| Capability | Description |
|------------|-------------|
| ✅ Git-native | Codex pulls from `main` and reads current state |
| ✅ Swift compiler integration | Full `swift build`, `swift test`, and `swift run` output is captured |
| ✅ Runs entirely on your VPS | No external runners are required |
| ✅ Semantic feedback loop | Codex writes JSON to `/feedback/`, patches are applied |
| ✅ Daemon architecture | One Python loop drives the whole system |
| ✅ Multi-repo awareness | Includes FountainAI, Kong, Typesense and Teatro sources in one repository |
| ✅ Developer-agnostic | Works whether code was committed by a human or Codex |
| ✅ GitHub sync | Build logs and applied patches automatically pushed |
| ✅ Log rotation | Each cycle writes `build-YYYYMMDD-HHMMSS.log` for history |
| ✅ Platform-aware compilation | Uses `xcrun` on macOS, open source Swift elsewhere |
| ✅ Codex-generated commits | Set `OPENAI_API_KEY` for semantic commit messages |
| ✅ Custom OpenAI endpoint | Set `OPENAI_API_BASE` to override the API URL used by the LLM Gateway. See [environment_variables.md](../environment_variables.md). |
| ✅ Docker builds & e2e tests | Set `DISPATCHER_BUILD_DOCKER=1` and `DISPATCHER_RUN_E2E=1` to build containers and run integration tests |

For a step-by-step explanation of how the dispatcher implements these features see [dispatcher_v2.md](../dispatcher_v2.md).

# 🌊 FountainAI

FountainAI is a self-hosting AI system built entirely in Swift 6.1. It compiles, tests and runs its services through the `FountainAiLauncher` without Docker or systemd. The previous architecture overview is archived in [`legacy/README.root-legacy.md`](legacy/README.root-legacy.md).

---

## Features

- **Swift 6.1 First** – all modules use the Swift Package Manager
- **Single Launcher** – `FountainAiLauncher` supervises every service
- **Feedback Loop** – commits produce build logs and await feedback in `/feedback`
- **Hetzner Native** – DNS and reverse proxy configuration managed via Swift scripts

---

## Repository Layout

```text
Sources/
├── FountainCore/
├── FountainAI/
├── FountainUI/
├── FountainOps/
├── FountainAgents/
FountainAiLauncher/
logs/
feedback/
Package.swift
```

---

## Quick Start

```bash
swift build -c release
swift test
.build/release/FountainAiLauncher
```

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

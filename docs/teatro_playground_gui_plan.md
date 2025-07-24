# TeatroPlayground: FountainAI UX Sandbox

This document describes a lightweight macOS application for experimenting with FountainAI user flows through a graphical interface. By providing a friendly UI, new contributors can explore Teatro components without editing shell scripts or environment files. The application serves as a sandbox for FountainAI UX experiments and demonstrates how Teatro renders interfaces.

## 1. Goals

1. Showcase Teatro views and layout capabilities on macOS.
2. Prototype interfaces that call FountainAI services.
3. Keep configuration values easily accessible via the UI.

## 2. Architecture Overview

- **Teatro Views** provide the declarative layout for forms, status indicators, and result consoles.
- A small Swift wrapper encapsulates clients for FountainAI services.
- Configuration values are stored in user-visible files managed through the UI.
- The same environment variables documented in [environment_variables.md](environment_variables.md) are respected, ensuring parity with the command-line workflow.

## 3. Basic UI Flow

1. The main window lists all editable settings with descriptions pulled from the environment documentation.
2. A "Start" button triggers FountainAI service operations.
3. Results appear in a scrolling text view rendered via Teatro, with color highlights for errors and warnings.
4. When running, a status indicator shows the current operation and last response.
5. Users can stop the process at any time or open referenced files in Finder for deeper inspection.

## 4. FountainAI Integration Path

TeatroPlayground begins as a playground for Teatro components, but it will grow into a launcher for FountainAI tools. Future iterations could:

- Display plan execution results from the Planner service.
- List reflections and baseline snapshots from the Awareness API.
- Provide quick actions for bootstrapping new corpora via the Bootstrap service.

## 5. Next Steps

1. Create a small Swift Package that embeds Teatro and exposes FountainAI service clients.
2. Prototype the settings form and response viewer using Teatro's SwiftUI preview support.
3. Iterate based on feedback, expanding the UI to cover additional services as FountainAI evolves.
4. Open `repos/TeatroPlayground/` in Xcode to preview `ContentView` and begin UI experimentation.

## Storyboard DSL Demo

`TeatroPlayground` now includes a **Storyboard Demo** experiment. It walks
through defining `Scene` blocks and `Transition` steps, then generates a textual
prompt via `CodexStoryboardPreviewer`. Use this demo to plan app states and
iterate on transitions before implementing real views.

---

By approaching Teatro with a dedicated macOS app, we lower the entry barrier for experimentation and pave the way for deeper FountainAI integrations.

``````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
``````

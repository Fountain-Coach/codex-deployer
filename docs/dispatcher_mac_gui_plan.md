# Dispatcher Mac GUI Concept

This document proposes a lightweight macOS application for controlling **dispatcher_v2.py** through a graphical interface. By providing a friendly UI, new contributors can experiment with dispatcher settings without editing shell scripts or environment files. The application uses the Teatro View Engine to render views and will also serve as an entry point for FountainAI features in the future.

## 1. Goals

1. Simplify configuration of environment variables such as `GITHUB_TOKEN` and `DISPATCHER_INTERVAL`.
2. Offer buttons to start, stop, and monitor the dispatcher process directly on macOS.
3. Present recent build logs and patch history in an accessible format.
4. Lay the groundwork for integrating FountainAI service clients once they become available.

## 2. Architecture Overview

- **Teatro Views** provide the declarative layout for forms, log consoles, and status indicators.
- A small Swift wrapper around **dispatcher_v2.py** launches the process and streams output to the UI.
- Configuration values are stored in a user-visible file (e.g. `dispatcher.env`) managed through the UI.
- The same environment variables documented in [environment_variables.md](environment_variables.md) are respected, ensuring parity with the command-line workflow.

## 3. Basic UI Flow

1. The main window lists all editable settings with descriptions pulled from the environment documentation.
2. A "Start Dispatcher" button spawns the Python loop as a child process and begins streaming logs.
3. Logs appear in a scrolling text view rendered via Teatro, with color highlights for errors and warnings.
4. When running, a status indicator shows the current cycle and last build result.
5. Users can stop the dispatcher at any time or open the log file in Finder for deeper inspection.

## 4. FountainAI Integration Path

While the initial release focuses on dispatcher controls, the same Teatro-based shell can host FountainAI tools. Future iterations could:

- Display plan execution results from the Planner service.
- List reflections and baseline snapshots from the Awareness API.
- Provide quick actions for bootstrapping new corpora via the Bootstrap service.

## 5. Next Steps

1. Create a small Swift Package that embeds Teatro and exposes the dispatcher process management code.
2. Prototype the settings form and log viewer using Teatro's SwiftUI preview support.
3. Iterate based on feedback, expanding the UI to cover additional services as FountainAI evolves.

---

By approaching the dispatcher as a macOS app, we lower the entry barrier for experimentation and pave the way for deeper FountainAI integrations.

```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```

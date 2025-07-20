# TeatroPlayground Concept

This document describes a lightweight macOS application for exploring Teatro features through a graphical interface. By providing a friendly UI, new contributors can experiment with Teatro components without editing shell scripts or environment files. The application serves as a playground for FountainAI tools and demonstrates how Teatro renders interfaces.

## 1. Goals

1. Showcase Teatro views and layout capabilities on macOS.
2. Experiment with launching helper processes such as `dispatcher_v2.py` from a GUI.
3. Display log output and patch history in an accessible format.
4. Provide a springboard for integrating FountainAI service clients once they become available.

## 2. Architecture Overview

- **Teatro Views** provide the declarative layout for forms, log consoles, and status indicators.
- A small Swift wrapper can launch helper processes such as **dispatcher_v2.py** and stream their output to the UI.
- Configuration values are stored in user-visible files (e.g. `dispatcher.env`) managed through the UI.
- The same environment variables documented in [environment_variables.md](environment_variables.md) are respected, ensuring parity with the command-line workflow.

## 3. Basic UI Flow

1. The main window lists all editable settings with descriptions pulled from the environment documentation.
2. A "Start" button can spawn helper processes such as the dispatcher loop and begin streaming logs.
3. Logs appear in a scrolling text view rendered via Teatro, with color highlights for errors and warnings.
4. When running, a status indicator shows the current cycle and last build result.
5. Users can stop the process at any time or open the log file in Finder for deeper inspection.

## 4. FountainAI Integration Path

TeatroPlayground begins as a playground for Teatro components, but it will grow into a launcher for FountainAI tools. Future iterations could:

- Display plan execution results from the Planner service.
- List reflections and baseline snapshots from the Awareness API.
- Provide quick actions for bootstrapping new corpora via the Bootstrap service.

## 5. Next Steps

1. Create a small Swift Package that embeds Teatro and exposes helper process management code.
2. Prototype the settings form and log viewer using Teatro's SwiftUI preview support.
3. Iterate based on feedback, expanding the UI to cover additional services as FountainAI evolves.
4. Open `repos/TeatroPlayground/` in Xcode to preview `ContentView` and begin UI experimentation.

---

By approaching Teatro with a dedicated macOS app, we lower the entry barrier for experimentation and pave the way for deeper FountainAI integrations.

````
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
````

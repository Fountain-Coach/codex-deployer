# TeatroPlayground – Official UX Playground for Teatro

![Swift](https://img.shields.io/badge/Swift-6.1-orange) ![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)

TeatroPlayground is the official UX playground for the [Teatro](../teatro) view engine. It bundles the `TeatroPlaygroundUI` library with a simple SwiftUI app so you can prototype and test Teatro components in a standalone environment.

## Build and Run

Run the package with Swift Package Manager:

```bash
swift build
swift run TeatroPlayground
```

## Installation

Add TeatroPlayground to your package dependencies if you want to embed the UI components:

```swift
.package(url: "https://github.com/fountain-coach/teatro.git", from: "0.1.0")
```



The Teatro dependency is fetched directly from GitHub, so no manual clone is required.

For live previews, open `ContentView.swift` in Xcode and use the SwiftUI preview canvas.

## Interactive Experiments

The main window now lists several demo scenes that highlight Teatro's building blocks.
Each experiment includes a short description and invites you to explore how views
compose and render. Choose an entry from the list to see the underlying Teatro
view in action.

The latest "Renderer Showcase" experiment now presents a dedicated SwiftUI view
that previews the Codex, HTML, SVG and PNG renderers side by side.

The new **Storyboard Demo** experiment teaches how to script app states using
the Storyboard DSL. It prints a frame-by-frame prompt via
`CodexStoryboardPreviewer` so you can iterate on transitions before coding the
actual UI. The demo walks through a small flow:

1. **Welcome** – Introduction screen.
2. **Login** – Simple form showing placeholder fields.
3. **Processing** – Short loading scene.
4. **Dashboard** – Confirmation view.

Transitions illustrate both crossfades and tweens. Select this entry to see the
generated prompt and adapt the storyboard for your own apps. A step-by-step
tutorial lives in [docs/storyboard_tutorial.md](../docs/storyboard_tutorial.md).


````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

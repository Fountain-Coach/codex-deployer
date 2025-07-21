# TeatroPlayground – Official UX Playground for Teatro

TeatroPlayground is the official UX playground for the [Teatro](../teatro) view engine. It bundles the `TeatroPlaygroundUI` library with a simple SwiftUI app so you can prototype and test Teatro components in a standalone environment.

## Build and Run

Run the package with Swift Package Manager:

```bash
swift build
swift run TeatroPlayground
```

This project also relies on the [Teatro](../teatro) package being available at `../teatro`. If the folder is missing, clone the repository before building:

```bash
git clone https://github.com/fountain-coach/teatro ../teatro
```

For live previews, open `ContentView.swift` in Xcode and use the SwiftUI preview canvas.

## Interactive Experiments

The main window now lists several demo scenes that highlight Teatro's building blocks.
Each experiment includes a short description and invites you to explore how views
compose and render. Choose an entry from the list to see the underlying Teatro
view in action.

The latest "Renderer Showcase" experiment now presents a dedicated SwiftUI view
that previews the Codex, HTML, SVG and PNG renderers side by side.


````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

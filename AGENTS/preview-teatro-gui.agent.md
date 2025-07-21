# preview-teatro-gui.agent.md

## 🧠 Purpose
Create a live SwiftUI Preview in Xcode for the `TeatroRootView` representing the “LLM-First” Typesense GUI. This enables developers to preview the dual-pane interface (chat + inspector) with mock data.

## 🛠️ Tools Required
- SwiftUI
- TeatroView module
- PreviewProvider using SwiftUI `#Preview`

## 🎯 Goals
- Provide a dual-pane `HStack` layout showing:
  - Left: `ChatWorkspaceView`
  - Right: `RetrievalInspectorView`
- Populate the view with mock Typesense hits and mock chat data.
- Ensure the preview is fully standalone and does not require a live Typesense backend.
- Wrap the preview in a `#if DEBUG` conditional to ensure it only compiles for preview builds.
- Apply a frame modifier to allow wide layout rendering in Xcode canvas or simulator.

## 🔒 Constraints
- **Do not call real Typesense endpoints.**
- Must compile without any external runtime services.
- Preview must run on macOS targets with SwiftUI support.
- All mock data must be scoped inside the preview block or test helpers.

## 🧾 Prompt Instruction for Codex
````swift
// Codex instruction:
// Create a working Xcode SwiftUI Preview for the `TeatroRootView` that shows the full dual-pane layout of the LLM-First Typesense GUI.
//
// 🧠 Purpose:
// Allow live iteration and snapshotting of the complete interface, including both the ChatWorkspaceView and the RetrievalInspectorView.
//
// ✅ Requirements:
// - Preview target must compile standalone (inject mock data or placeholders as needed).
// - `TeatroRootView` should use `HStack` with `ChatWorkspaceView()` on the left and `RetrievalInspectorView()` on the right.
// - Provide `.frame(minWidth: 800, idealWidth: 1280, maxWidth: .infinity)` to allow wide layout.
// - Wrap preview in `#if DEBUG` and `PreviewProvider` using `Preview { ... }`.
// - Mock `TypesenseHit` and LLM response data inside the preview only—no production Typesense calls.
//
// 🔧 Preview Example Implementation:
#if DEBUG
import SwiftUI

@MainActor
#Preview("LLM-First Typesense GUI") {
    TeatroRootView(
        chat: .mock(),
        hits: [
            TypesenseHit(id: "production-guide", score: 57.93, highlight: "Typesense can be run in production with the following resources…", distance: 0.364)
        ]
    )
    .frame(minWidth: 800, idealWidth: 1280, maxWidth: .infinity, minHeight: 600)
}
#endif
```
````

`````text
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
`````

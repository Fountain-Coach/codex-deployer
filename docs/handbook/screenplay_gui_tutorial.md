# ScreenplayGUI Tutorial

*Modifying the preview app and injected blocks.*

ScreenplayGUI lives under `repos/fountainai/ScreenplayGUI`. Open this package in Xcode to experiment with fonts, layout, and script injection.

## Opening the package

1. Launch Xcode and choose **File → Open**.
2. Navigate to `repos/fountainai/ScreenplayGUI` and select `Package.swift`.
3. Xcode indexes the package and exposes targets like `ScreenplayGUIApp` and `PreviewHost` for previews.

## Using SwiftUI previews

- Open `DirectiveBlockView.swift` or `ScreenplayMainStage.swift` in the navigator.
- Activate the canvas or the preview button. Changes to text modifiers or layout update instantly.
- The main preview at the bottom of `ScreenplayMainStage.swift` shows the DIN A4 layout.

## How injected blocks appear

`ScriptExecutionEngine` parses the screenplay and inserts tool responses after trigger lines. Each injection is rendered by `DirectiveBlockView`.

To customize them:

1. Edit the `injectedView(for:)` switch in `DirectiveBlockView` to adjust fonts or colors.
2. Extend `handle(_:after:)` in `ScriptExecutionEngine` to insert new block types.

## Adapting fonts and layout

- Modify the `.font` modifier in `ScreenplayMainStage` to change the global appearance.
- Tweak the `LazyVStack` and container padding to adjust margins.
- Add or remove injected blocks by editing your script in `ScriptEditorStageView` and observing how the engine updates the preview.

This workflow lets you iterate quickly in Xcode before committing changes back to the repository.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

# LLM-First GUI – Status and Next Steps

This document tracks progress on the chat-centric Typesense interface proposed in [llm_first_typesense_gui.md](../llm_first_typesense_gui.md).

## Current Status

- `ChatWorkspaceView` sends prompts to `LLMService` and renders replies but does not stream tokens or show citations.
- `RetrievalInspectorView` displays raw Typesense hits but is not wired into the chat workflow.
- `PromptHistoryView`, `CollectionBrowserView`, `SchemaEditorView` and `OpsDashboardView` exist as separate views but are not combined into the dual-pane layout.
- The Typesense client generation script in `TeatroView` works but lacks live reload hooks.
- `ScreenplayGUI` project scaffold added under `repos/fountainai/ScreenplayGUI`.
- Main `ScriptEditorStage` view renders a single-page editor styled like a PDF.
- Xcode preview now shows the editor as a sheet of paper on a desktop.
- `ScreenplayMainStage` centers the PDF-like editor on a desk background and adds a right-side inspector placeholder.

## Next Steps

1. Integrate `RetrievalInspectorView` with the chat pane so Typesense hits appear side by side when `typesense.search` is invoked.
2. Extend `LLMService` to stream responses and surface citation chips in the chat UI.
3. Expose `PromptHistoryView` and `OpsDashboardView` as tabs in `TeatroRootView`.
4. Connect `CollectionBrowserView` and `SchemaEditorView` for in-chat corpus management.
5. Add live reload hooks so GUI changes trigger automatic rebuilds.
6. Document any new environment variables in [environment_variables.md](../environment_variables.md).
7. Hook the new ScreenplayGUI into the editor workflow as outlined in Docs/FountainAI GUI proposal.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

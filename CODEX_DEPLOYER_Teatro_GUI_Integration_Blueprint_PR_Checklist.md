# codex-deployer — Teatro GUI Integration Blueprint & PR Checklist

**Status:** Proposal ready for PR  
**Audience:** codex-deployer maintainers and contributors  
**Scope:** Add a `FountainGui` target (headless) and an optional `FountainGuiMac` (macOS wrapper) that exclusively use Teatro as the GUI provider via `TeatroRenderAPI`. Provide CLI entrypoints with file watching and live preview served through the existing Gateway/Publishing frontend.

---

## 1) Goals & Non‑Goals

### Goals
- Integrate **Teatro** (via `TeatroRenderAPI`) as the **only** GUI/rendering engine.
- Provide a single CLI surface: `fountainai gui <mode> <input> [--serve] [--out <dir>]`.
- Support **Linux (headless)** and **macOS (SwiftUI wrapper)**, sharing the same render core.
- Auto-serve previews through codex-deployer’s existing **PublishingFrontend**.
- Wire **MemoryOverlay** UI to the local Gateway (config‑driven, tokenized).

### Non‑Goals
- Implement rendering logic here (lives in Teatro).
- Add new backends for persistence (reuse Gateway endpoints already available).

---

## 2) SPM Wiring

Add Teatro and the renderer templates as dependencies, then define `FountainGui` (CLI) and `FountainGuiMac` (macOS).

```swift
// Package.swift (excerpt)
dependencies: [
    .package(url: "https://github.com/Fountain-Coach/Teatro.git", branch: "main")
    // Optionally: .package(url: "https://github.com/Fountain-Coach/FountainAI-Teatro-Template.git", branch: "main")
],
targets: [
    .executableTarget(
        name: "FountainAiLauncher",
        dependencies: ["FountainGui" /*, existing targets */]
    ),
    .target(
        name: "FountainGui",
        dependencies: ["TeatroRenderAPI"],
        resources: [.process("Resources")]
    ),
    #if os(macOS)
    .target(
        name: "FountainGuiMac",
        dependencies: ["TeatroRenderAPI"],
        resources: [.process("Resources")]
    ),
    #endif
]
```

---

## 3) Directory Layout

```
Sources/
  FountainAiLauncher/              # existing launcher (stays)
  FountainGui/                     # NEW headless CLI + watcher + persistence
    GuiCommand.swift
    FileWatcher.swift
    MemoryClient.swift
    Persist.swift
    CLI.swift
  FountainGuiMac/                  # NEW macOS SwiftUI host (optional build)
    App.swift
    Views/
      ScriptEditorView.swift
      StoryboardView.swift
      SessionView.swift
Resources/
  Keybindings.md
docs/preview/                      # when --serve; PublishingFrontend serves from here
```

---

## 4) CLI Surface

```
fountainai gui script <path/to/scene.fountain> [--serve] [--out <dir>]
fountainai gui storyboard <path/to/timeline.{ump,storyboard}> [--serve] [--out <dir>]
fountainai gui session <path/to/log.session|.log|.md> [--serve] [--out <dir>]
```

- **`--serve`**: write into `docs/preview/` and trigger a PublishingFrontend reload.
- **`--out`**: override output directory (default: `./docs/preview` when `--serve`, else `./out`).

**CLI.swift (skeleton)**

```swift
// Sources/FountainGui/CLI.swift

import Foundation

enum GuiMode { case script, storyboard, session }

struct GuiOptions {
    let inputURL: URL
    let outputDir: URL
    let serve: Bool
}

@main
struct FountainGuiCLI {
    static func main() throws {
        // parse CommandLine.arguments or use ArgumentParser if present
        // map to GuiMode + GuiOptions
        // call GuiCommand.run(mode:options:)
    }
}
```

---

## 5) Headless Implementation

**GuiCommand.swift (skeleton)**

```swift
// Sources/FountainGui/GuiCommand.swift

import Foundation
import TeatroRenderAPI

enum GuiError: Error { case invalidInput(String) }

enum GuiMode { case script, storyboard, session }

struct GuiOptions {
    let inputURL: URL
    let outputDir: URL
    let serve: Bool
}

enum GuiCommand {
    static func run(mode: GuiMode, options: GuiOptions) throws {
        let watcher = FileWatcher(input: options.inputURL)
        try renderOnce(mode: mode, inputURL: options.inputURL, outputDir: options.outputDir, alsoServe: options.serve)
        watcher.onChange = { _ in try? renderOnce(mode: mode, inputURL: options.inputURL, outputDir: options.outputDir, alsoServe: options.serve) }
        watcher.start()
        RunLoop.current.run()
    }

    private static func renderOnce(mode: GuiMode, inputURL: URL, outputDir: URL, alsoServe: Bool) throws {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        switch mode {
        case .script:
            let text = try String(contentsOf: inputURL)
            let result = try TeatroRenderer.renderScript(SimpleScriptInput(fountainText: text))
            try Persist.write(result, basename: inputURL.deletingPathExtension().lastPathComponent, to: outputDir)
        case .storyboard:
            let data = try Data(contentsOf: inputURL)
            let result = try TeatroRenderer.renderStoryboard(SimpleStoryboardInput(umpData: data, storyboardDSL: nil))
            try Persist.write(result, basename: inputURL.deletingPathExtension().lastPathComponent, to: outputDir)
        case .session:
            let text = try String(contentsOf: inputURL)
            let result = try TeatroRenderer.renderSession(SimpleSessionInput(logText: text))
            try Persist.write(result, basename: inputURL.deletingPathExtension().lastPathComponent, to: outputDir)
        }
        if alsoServe { PublishingFrontend.reload() } // implement as a no-op if not present
    }
}
```

**Persist.swift (skeleton)**

```swift
// Sources/FountainGui/Persist.swift

import Foundation
import TeatroRenderAPI

enum Persist {
    static func write(_ result: RenderResult, basename: String, to dir: URL) throws {
        if let svg = result.svg { try svg.write(to: dir.appendingPathComponent("\(basename).svg")) }
        if let md = result.markdown { try md.data(using: .utf8)?.write(to: dir.appendingPathComponent("\(basename).md")) }
        if let ump = result.ump { try ump.write(to: dir.appendingPathComponent("\(basename).ump")) }
    }
}
```

**FileWatcher.swift** should use **inotify** on Linux and **DispatchSource** on macOS, wrapped behind a small protocol.

---

## 6) macOS Wrapper (optional build)

```swift
// Sources/FountainGuiMac/App.swift

import SwiftUI
import TeatroRenderAPI

@main
struct FountainGuiApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: FountainScriptDocument()) { file in
            ScriptEditorView(document: file.$document)
                .commands {
                    CommandMenu("Run") {
                        Button("Render") { file.document.render() }.keyboardShortcut("r", modifiers: .command)
                        Button("Save") { file.document.save() }.keyboardShortcut("s", modifiers: .command)
                    }
                }
        }
    }
}
```

**ScriptEditorView.swift (skeleton)**

```swift
import SwiftUI
import TeatroRenderAPI

struct ScriptEditorView: View {
    @Binding var document: FountainScriptDocument
    @State private var svgData: Data?

    var body: some View {
        HStack {
            TextEditor(text: $document.text).font(.system(.body, design: .monospaced))
            Divider()
            if let svgData { TeatroPlayerView(svgData: svgData) }
            else { Text("Render (⌘R) to preview") }
        }
        .onAppear { try? render() }
    }

    func render() throws {
        let result = try TeatroRenderer.renderScript(SimpleScriptInput(fountainText: document.text))
        svgData = result.svg
    }
}
```

---

## 7) MemoryOverlay (Gateway integration)

Create a tiny client to call the local Gateway (URL + token from config).

```swift
// Sources/FountainGui/MemoryClient.swift

import Foundation

struct MemoryHit: Decodable { let id: String; let title: String; let snippet: String }

enum MemoryClient {
    static var baseURL: URL { URL(string: Config.gatewayBaseURL)! }
    static func search(_ q: String) async throws -> [MemoryHit] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("/search"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "q", value: q)]
        var req = URLRequest(url: comps.url!)
        req.addValue("Bearer \(Config.token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode([MemoryHit].self, from: data)
    }
}
```

**Config** (values injected from centralized `.env` or `gui.yml`):
- `GUI_GATEWAY_BASE_URL` (e.g., `http://localhost:PORT`)
- `GUI_GATEWAY_TOKEN`
- `GUI_OUTPUT_DIR` (default when not using `--out`)

---

## 8) Tests & CI

- **Snapshot tests** for CLI (`fountainai gui ...`) writing expected outputs.
- **Watcher test**: simulate file change and assert re-render.
- **macOS smoke test** (if the wrapper is built) that `ScriptEditorView` compiles.
- Run in CI on Linux + macOS runners.

Directory:
```
Tests/FountainGuiTests/
  CLIRenderTests.swift
  WatcherTests.swift
  __snapshots__/
```

---

## 9) PR Checklist (codex-deployer)

**Branch**: `feat/teatro-gui-integration`  
**PR Title**: `feat(gui): integrate Teatro via TeatroRenderAPI (CLI + optional macOS host)`

- [ ] Add SPM dependency on `Teatro` (and `TeatroRenderAPI` product).
- [ ] Create `FountainGui` target with CLI, watcher, persist utilities.
- [ ] Implement `GuiCommand` with `script|storyboard|session` modes.
- [ ] Wire `--serve` to write to `docs/preview/` and trigger PublishingFrontend.
- [ ] Add `FountainGuiMac` (optional macOS SwiftUI host) with `ScriptEditorView`, `StoryboardView`, `SessionView` embedding `TeatroPlayerView`.
- [ ] Add `gui.yml` and environment variable bindings for Gateway and defaults.
- [ ] Add snapshot tests for CLI outputs.
- [ ] Update docs: `docs/teatro-gui.md` explaining usage & config.
- [ ] CI: ensure Linux + macOS builds green.
- [ ] Tag release `vX.Y.Z` once Teatro dependency with `TeatroRenderAPI` is released.

**Acceptance Criteria**
- `fountainai gui script …` produces `.svg` (and `.md` when applicable) deterministically.
- `--serve` exposes outputs via existing PublishingFrontend.
- macOS host renders SVG previews using `TeatroPlayerView` (if built).

**Rollback Plan**
- Disable `FountainGui` from launcher; keep code behind feature flag.
- Revert PR if necessary; no data migration.

---

## 10) Codex Action Block

Add this to `agent.md` (or keep in this file) to let Codex execute changes automatically:

```yaml
codex:
  intent: "Integrate Teatro as the exclusive GUI provider via TeatroRenderAPI"
  branch: "feat/teatro-gui-integration"
  tasks:
    - path: "Package.swift"
      action: "edit"
      description: "Add Teatro dependency; create FountainGui and FountainGuiMac targets"
    - path: "Sources/FountainGui/CLI.swift"
      action: "create"
      contents: "<paste from Section 4>"
    - path: "Sources/FountainGui/GuiCommand.swift"
      action: "create"
      contents: "<paste from Section 5>"
    - path: "Sources/FountainGui/Persist.swift"
      action: "create"
      contents: "<paste from Section 5>"
    - path: "Sources/FountainGui/FileWatcher.swift"
      action: "create"
      contents: "<platform-conditional inotify/DispatchSource implementation>"
    - path: "Sources/FountainGui/MemoryClient.swift"
      action: "create"
      contents: "<paste from Section 7>"
    - path: "docs/teatro-gui.md"
      action: "create"
      contents: "Usage, CLI reference, config keys, troubleshooting"
  open_pr:
    title: "feat(gui): integrate Teatro via TeatroRenderAPI (CLI + optional macOS host)"
    body: "Adds headless CLI rendering, live preview via PublishingFrontend, and optional macOS SwiftUI wrapper."
    reviewers: ["Fountain-Coach/codex-deployer-maintainers"]
    labels: ["feature", "gui", "teatro", "integration"]
```

---

## 11) Rollout Steps

1. Land Teatro’s `TeatroRenderAPI` (minor version bump).
2. Update `codex-deployer` dependency to new Teatro tag.
3. Merge this PR; verify CLI renders fixtures.
4. (Optional) Build macOS wrapper and validate live preview.
5. Enable `--serve` in CI demo job and publish `docs/preview` artifacts.

## 4. CLI Integration

The Teatro View Engine includes a lightweight command-line interface (CLI) implementation for rendering any `Renderable` to a chosen output format. This enables scripting, automation, or integration with external developer tools.

---

### RenderCLI

```swift
public enum RenderTarget: String {
    case html, svg, png, codex
}
```

This enum defines supported output formats.

```swift
public struct RenderCLI {
    public static func main(args: [String]) {
        let view = Stage(title: "CLI Demo") {
            VStack(alignment: .center, padding: 2) {
                TeatroIcon("🎭")
                Text("CLI Renderer", style: .bold)
            }
        }

        let target = RenderTarget(rawValue: args.first ?? "codex") ?? .codex

        switch target {
        case .html:
            print(HTMLRenderer.render(view))
        case .svg:
            print(SVGRenderer.render(view))
        case .png:
            ImageRenderer.renderToPNG(view)
        case .codex:
            print(CodexPreviewer.preview(view))
        }
    }
}
```

---

### Usage

```bash
swift run RenderCLI html
swift run RenderCLI svg
swift run RenderCLI png
swift run RenderCLI codex
```

This CLI is ideal for:
- Previewing scenes, tests, or examples from terminal
- Connecting renderable output to other tools (e.g., orchestration logs, build pipelines)
- Rendering `.fountain`, `.mid`, or `.ly` views via CLI with extended routing


import Teatro
public enum RenderTarget: String {
    case html, svg, png, codex
}

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

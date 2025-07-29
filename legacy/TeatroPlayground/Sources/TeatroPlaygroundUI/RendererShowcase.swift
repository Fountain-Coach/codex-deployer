import Teatro

public struct RendererShowcase: Renderable {
    public init() {}
    public func render() -> String {
        let demo = Stage(title: "Render Showcase") {
            VStack(alignment: .center, padding: 1) {
                TeatroIcon("🎭")
                Text("Playground Demo", style: .bold)
            }
        }
        var result = "-- Codex Preview --\n"
        result += CodexPreviewer.preview(demo)
        result += "\n\n-- HTML --\n"
        result += HTMLRenderer.render(demo)
        result += "\n\n-- SVG --\n"
        result += SVGRenderer.render(demo)
        ImageRenderer.renderToPNG(demo, to: "renderer_demo.png")
        result += "\n\nPNG output written to renderer_demo.png"
        return result
    }
}

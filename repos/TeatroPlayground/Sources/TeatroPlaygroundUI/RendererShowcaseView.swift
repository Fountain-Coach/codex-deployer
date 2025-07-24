#if canImport(SwiftUI)
import SwiftUI
import Teatro
#if canImport(WebKit)
import WebKit
#endif

/// SwiftUI view showcasing multiple renderer outputs.
public struct RendererShowcaseView: View, Renderable {
    let demo: Stage
    public init() {
        demo = Stage(title: "Render Showcase") {
            VStack(alignment: .center, padding: 1) {
                TeatroIcon("🎭")
                Text("Playground Demo", style: .bold)
            }
        }
    }

    public nonisolated func render() -> String {
        RendererShowcase().render()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                section(title: "Codex Preview") {
                    Text(CodexPreviewer.preview(demo))
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                section(title: "HTML") {
                    WebPreview(html: HTMLRenderer.render(demo))
                        .frame(height: 200)
                }
                section(title: "SVG") {
                    svgImage()
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
                section(title: "PNG") {
                    pngImage()
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
            }
            .padding()
        }
    }

    private func section<Content: View>(title: String, @SViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }

    private func svgImage() -> Image {
        let svg = SVGRenderer.render(demo)
        guard let data = svg.data(using: .utf8) else {
            return Image(systemName: "xmark.octagon")
        }
#if os(macOS)
        if let img = NSImage(data: data) { return Image(nsImage: img) }
#elseif canImport(UIKit)
        if let img = UIImage(data: data) { return Image(uiImage: img) }
#endif
        return Image(systemName: "xmark.octagon")
    }

    private func pngImage() -> Image {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("renderer_demo.png")
        ImageRenderer.renderToPNG(demo, to: url.path)
#if os(macOS)
        if let img = NSImage(contentsOf: url) { return Image(nsImage: img) }
#elseif canImport(UIKit)
        if let img = UIImage(contentsOfFile: url.path) { return Image(uiImage: img) }
#endif
        return Image(systemName: "xmark.octagon")
    }
}

#if canImport(WebKit)
private struct WebPreview: NSViewRepresentable {
    let html: String
    func makeNSView(context: Context) -> WKWebView { WKWebView() }
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(html, baseURL: nil)
    }
}
#else
private struct WebPreview: View {
    let html: String
    var body: some View {
        Text(html).font(.system(.body, design: .monospaced))
    }
}
#endif
#endif

#if !canImport(SwiftUI)
import Teatro
public struct RendererShowcaseView: Renderable {
    public init() {}
    public func render() -> String {
        RendererShowcase().render()
    }
}
#endif


#if DEBUG
#Preview("Renderer Showcase") {
    RendererShowcaseView()
        .frame(width: 800, height: 600)
        .preferredColorScheme(.dark)
}
#endif

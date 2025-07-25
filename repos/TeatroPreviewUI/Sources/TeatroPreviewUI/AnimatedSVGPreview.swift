#if canImport(SwiftUI) && canImport(WebKit)
import SwiftUI
import WebKit
import Teatro

#if os(macOS)
public struct AnimatedSVGPreview: NSViewRepresentable {
    let svg: String

    public init(svg: String) {
        self.svg = svg
    }

    public func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head><meta charset=\"utf-8\"></head>
        <body style=\"margin:0; background:transparent;\">
        \(svg)
        </body>
        </html>
        """
        nsView.loadHTMLString(html, baseURL: nil)
    }
}
#else
public struct AnimatedSVGPreview: UIViewRepresentable {
    let svg: String

    public init(svg: String) {
        self.svg = svg
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head><meta charset=\"utf-8\"></head>
        <body style=\"margin:0; background:transparent;\">
        \(svg)
        </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
#endif

#if canImport(SwiftUI) && DEBUG
#Preview {
    let storyboard = Storyboard {
        Scene("Intro") {
            VStack {
                Text("Hello Teatro", style: .bold)
                Text("SVG in motion")
            }
        }
        Transition(style: .crossfade, frames: 10)
        Scene("Next") {
            VStack {
                Text("Second Scene")
            }
        }
    }

    let svg = SVGAnimator.renderAnimatedSVG(storyboard: storyboard)
    return AnimatedSVGPreview(svg: svg)
        .frame(width: 600, height: 300)
}
#endif
#endif

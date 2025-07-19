#if canImport(SwiftUI)
import SwiftUI
import Teatro

struct TeatroRenderView: View {
    let content: Renderable
    var body: some View {
        Text(content.render())
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color(NSColor.textBackgroundColor))
    }
}
#else
import Teatro

public struct TeatroRenderView {
    public let content: Renderable
    public init(content: Renderable) {
        self.content = content
    }
}
#endif

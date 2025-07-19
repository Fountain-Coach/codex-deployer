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

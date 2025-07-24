#if canImport(SwiftUI)
import SwiftUI

/// Text input overlay used for bootstrapping FountainAI scripts.
public struct StoryInputOverlay: View {
    @Binding var text: String
    var inlineMode: Bool
    var onCommit: () -> Void

    public init(text: Binding<String>, inlineMode: Bool = false, onCommit: @escaping () -> Void) {
        self._text = text
        self.inlineMode = inlineMode
        self.onCommit = onCommit
    }

    public var body: some View {
        HStack {
            if inlineMode {
                Button(action: onCommit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .buttonStyle(.plain)
            } else {
                TextField("What's your story?", text: $text, onCommit: onCommit)
                    .textFieldStyle(.roundedBorder)
                Button(action: onCommit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 10)
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI

/// Root stage combining the screenplay editor with future inspector panes.
public struct ScreenplayMainStage: View {
    @State private var script: String

    public init(script: String = ScriptEditorStage.defaultScript) {
        _script = State(initialValue: script)
    }

    public var body: some View {
        HStack(spacing: 0) {
            ScriptEditorStageView(script: script)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Placeholder for right pane inspector
            Color.gray.opacity(0.1)
                .frame(width: 300)
        }
    }
}

#Preview("Main Stage") {
    ScreenplayMainStage()
        .frame(width: 1100, height: 900)
}
#endif

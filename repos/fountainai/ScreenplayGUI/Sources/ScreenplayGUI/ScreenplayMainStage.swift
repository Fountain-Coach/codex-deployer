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
            Divider()
            VStack {
                Text("Inspector")
                    .font(.headline)
                Spacer()
            }
            .frame(width: 280)
            .background(Color.gray.opacity(0.1))
        }
    }
}

#Preview("Main Stage") {
    ScreenplayMainStage()
        .frame(width: 1100, height: 900)
}
#endif

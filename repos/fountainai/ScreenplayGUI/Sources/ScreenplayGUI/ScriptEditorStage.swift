import Teatro

public enum ScriptEditorStage {
    public static let defaultScript = """
    Title: Sample

    INT. LAB - DAY

    DEVELOPER
    Let's integrate Teatro!
    """
}

#if canImport(SwiftUI)
import SwiftUI

public struct ScriptEditorStageView: View {
    @State private var scriptText: String

    public init(script: String = ScriptEditorStage.defaultScript) {
        _scriptText = State(initialValue: script)
    }

    public var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            ScrollView {
                TextEditor(text: $scriptText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(width: 595, height: 842) // A4 size in points
                    .background(Color.white)
                    .cornerRadius(4)
                    .shadow(radius: 5)
                    .padding()
            }
        }
    }
}

#if DEBUG

#Preview("Screenplay Editor Stage") {
    ScriptEditorStageView()
        .frame(width: 800, height: 900)
}
#endif
#endif

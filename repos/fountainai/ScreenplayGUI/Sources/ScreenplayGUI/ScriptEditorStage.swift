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
import AppKit


public struct ScriptEditorStageView: View {
    @State private var scriptText: String

    public init(script: String = ScriptEditorStage.defaultScript) {
        _scriptText = State(initialValue: script)
    }

    public var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor).ignoresSafeArea()
            ScrollView(.vertical) {
                HStack {
                    Spacer(minLength: 0)
                    TextEditor(text: $scriptText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding()
                        .frame(width: 595, height: 842)
                        .background(Color.white)
                        .cornerRadius(4)
                        .shadow(radius: 5)
                        .padding()
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

#Preview("Screenplay Editor Stage") {
    ScriptEditorStageView()
        .frame(width: 800, height: 900)
}
#endif

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ScriptEditorStage_Previews: PreviewProvider {
    static var previews: some View {
        ScriptEditorStageView()
    }
}
#endif

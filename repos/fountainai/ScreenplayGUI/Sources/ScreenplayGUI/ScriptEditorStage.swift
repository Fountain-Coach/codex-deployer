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

final class ScriptEditorViewModel: ObservableObject {
    @Published var scriptText: String
    @Published var blocks: [FountainDirective] = []
    private let engine = ScriptExecutionEngine()

    init(script: String) {
        self.scriptText = script
    }

    func run() {
        blocks = engine.execute(script: scriptText)
    }
}

public struct ScriptEditorStageView: View {
    @StateObject private var viewModel: ScriptEditorViewModel

    public init(script: String = ScriptEditorStage.defaultScript) {
        _viewModel = StateObject(wrappedValue: ScriptEditorViewModel(script: script))
    }

    public var body: some View {
        ScrollView {
            ForEach(viewModel.blocks) { block in
                DirectiveBlockView(block: block)
            }
        }
        .onAppear { viewModel.run() }
        .toolbar {
            Button("Run Script") { viewModel.run() }
                .keyboardShortcut(.return, modifiers: .command)
        }
    }
}

#Preview("Screenplay Editor Stage") {
    ScriptEditorStageView()
        .frame(width: 600, height: 800)
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

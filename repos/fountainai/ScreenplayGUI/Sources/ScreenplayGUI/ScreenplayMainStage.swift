#if canImport(SwiftUI)
import SwiftUI

/// Root stage combining the screenplay editor with future inspector panes.
public struct ScreenplayMainStage: View {
    @StateObject var viewModel = ScriptExecutionEngine()

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.blocks) { block in
                    DirectiveBlockView(block: block)
                }
            }
            .padding()
        }
        .toolbar {
            Button("Run Script") {
                viewModel.run()
            }
        }
        .onAppear { viewModel.run() }
    }
}

#Preview("Main Stage") {
    ScreenplayMainStage()
        .frame(width: 1100, height: 900)
}
#endif

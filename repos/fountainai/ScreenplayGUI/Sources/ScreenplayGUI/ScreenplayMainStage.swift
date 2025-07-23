#if canImport(SwiftUI)
import SwiftUI

/// Root stage presenting the screenplay as a single scrolling page.
public struct ScreenplayMainStage: View {
    @StateObject var viewModel = ScriptExecutionEngine()

    public init() {}

    public var body: some View {
        ZStack {
            Color(white: 0.94).ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.blocks) { block in
                        DirectiveBlockView(block)
                    }
                }
                .frame(maxWidth: 700)
                .padding(48)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 20)
                .padding(.vertical, 60)
            }
        }
        .font(.system(.body, design: .monospaced))
        .onAppear { viewModel.run() }
    }
}

#endif

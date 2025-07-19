#if canImport(SwiftUI)
import SwiftUI
import Teatro

public struct ContentView: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dispatcher GUI")
                .font(.title)
            Button("Start Dispatcher") {
                print("Start dispatcher tapped")
            }
            TeatroRenderView(prompt: DispatcherPrompt())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

#if canImport(SwiftUI) && DEBUG && !SWIFT_PACKAGE
#Preview {
    ContentView()
}
#endif
#endif

#if canImport(SwiftUI)
import SwiftUI
import Teatro

public struct ContentView: View {
    public init() {}
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dispatcher GUI")
                .font(.title)
            Button("Start Dispatcher") {
                print("Start dispatcher tapped")
            }
            TeatroRenderView(content: DispatcherPrompt())
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
#else
import Teatro

public struct ContentView {
    public init() {}
}
#endif

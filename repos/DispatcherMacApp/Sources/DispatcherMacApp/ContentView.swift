#if canImport(SwiftUI)
import SwiftUI
import Teatro

struct ContentView: View {
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

#if canImport(SwiftUI) && DEBUG
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

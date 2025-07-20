#if canImport(SwiftUI)
import SwiftUI

/// Blank container view for FountainAI UX experiments.
public struct ContentView: View {
    public init() {}

    public var body: some View {
        Text("FountainAI UX experiments")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if canImport(SwiftUI)
#Preview {
    ContentView()
}
#endif
#endif

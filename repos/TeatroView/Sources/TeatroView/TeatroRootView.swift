import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Root view replicating `TeatroApp`'s tab layout so it can be previewed.
public struct TeatroRootView: View {
    public init() {}
    public var body: some View {
        TabView {
            ChatWorkspaceView()
                .tabItem { Text("Chat") }

            CollectionBrowserView(service: .live)
                .tabItem { Text("Collections") }
        }
    }
}

#if DEBUG
#Preview {
    TeatroRootView()
}
#endif
#endif

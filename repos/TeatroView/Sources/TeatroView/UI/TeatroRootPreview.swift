import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Root view replicating `TeatroApp`'s tab layout for SwiftUI previews.
public struct TeatroRootPreview: View {
    /// Default initializer for preview usage.
    public init() {}

    public var body: some View {
        TabView {
            ChatWorkspaceView()
                .tabItem { Text("Chat") }

            CollectionBrowserView(names: ["books", "articles"])
                .tabItem { Text("Collections") }
        }
    }
}

#if DEBUG
#Preview {
    TeatroRootPreview()
}
#endif
#endif

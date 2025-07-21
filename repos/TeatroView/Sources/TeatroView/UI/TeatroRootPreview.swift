import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Preview container replicating the tabbed layout from `TeatroApp` for SwiftUI previews.
struct TeatroRootPreview: View {
    var body: some View {
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
    TeatroRootPreview()
}
#endif
#endif

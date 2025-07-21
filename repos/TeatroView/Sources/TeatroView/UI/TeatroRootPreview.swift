import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// This preview-only container mirrors the tab layout of `TeatroApp` without
/// conflicting with the production `TeatroRootView` implementation.

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

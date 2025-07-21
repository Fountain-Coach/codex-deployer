import Teatro
#if canImport(SwiftUI)
import SwiftUI


struct TeatroApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ChatWorkspaceView()
                    .tabItem { Text("Chat") }
                CollectionBrowserView(service: .live)
                    .tabItem { Text("Collections") }
            }
        }
    }
}
#else
// Running outside of SwiftUI-capable platforms.
#endif

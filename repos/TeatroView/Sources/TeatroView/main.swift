import Teatro
#if canImport(SwiftUI)
import SwiftUI

@main
struct TeatroApp: App {
    var body: some Scene {
        WindowGroup {
            CollectionBrowserView(service: .live)
        }
    }
}
#else
// Running outside of SwiftUI-capable platforms.
#endif

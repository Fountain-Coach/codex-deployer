#if canImport(SwiftUI)
import SwiftUI
import TeatroView

struct ContentView: View {
    var body: some View {
        CollectionBrowserView_Previews.previews
    }
}

@main
struct TeatroViewPreviewHostApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#else
import Foundation

@main
struct TeatroViewPreviewHostApp {
    static func main() {
        print("SwiftUI not available")
    }
}
#endif

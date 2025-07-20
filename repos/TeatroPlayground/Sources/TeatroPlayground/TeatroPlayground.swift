#if canImport(SwiftUI)
import SwiftUI
import TeatroPlaygroundUI

@main
struct GUITeatroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#else
import Foundation

@main
struct GUITeatroApp {
    static func main() {
        print("GUITeatro stub - SwiftUI unavailable")
    }
}
#endif

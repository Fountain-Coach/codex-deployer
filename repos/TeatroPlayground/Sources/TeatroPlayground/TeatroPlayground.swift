#if canImport(SwiftUI)
import SwiftUI
import TeatroPlaygroundUI
import Teatro

public typealias TViewBuilder = Teatro.ViewBuilder
public typealias SViewBuilder = SwiftUI.ViewBuilder

@main
struct GUITeatroApp: App {
    var body: some Scene {
        WindowGroup {
            TeatroPlaygroundUI.ContentView()
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

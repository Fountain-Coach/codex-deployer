#if canImport(SwiftUI)
import SwiftUI
import DispatcherUI
import Teatro

public typealias TViewBuilder = Teatro.ViewBuilder
public typealias SViewBuilder = SwiftUI.ViewBuilder

@main
struct DispatcherMacApp: App {
    var body: some Scene {
        WindowGroup {
            DispatcherUI.ContentView()
        }
    }
}
#else
import Foundation

@main
struct DispatcherMacApp {
    static func main() {
        print("DispatcherMacApp stub - SwiftUI unavailable")
    }
}
#endif

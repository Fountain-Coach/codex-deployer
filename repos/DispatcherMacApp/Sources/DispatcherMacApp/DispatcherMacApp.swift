#if canImport(SwiftUI)
import SwiftUI
import DispatcherUI
import Teatro

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

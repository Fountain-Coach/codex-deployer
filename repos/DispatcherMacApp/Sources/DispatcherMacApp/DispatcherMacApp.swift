#if canImport(SwiftUI)
import SwiftUI

@main
struct DispatcherMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
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

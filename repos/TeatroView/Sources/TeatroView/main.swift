import Teatro
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Entry point for the TeatroView package.
#if canImport(SwiftUI)

@main
struct TeatroViewApp: App {
    var body: some Scene {
        WindowGroup {
            Text("TeatroView Placeholder")
        }
    }
}
#else
print("TeatroView requires SwiftUI and macOS to run.")
#endif

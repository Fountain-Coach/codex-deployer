import Teatro
#if canImport(SwiftUI)
import SwiftUI

@main
struct TeatroViewApp: App {
    var body: some Scene {
        WindowGroup {
            Text("TeatroView Placeholder")
        }
    }
}
#else
@main
struct TeatroViewCLI {
    static func main() {
        print("TeatroView requires SwiftUI and macOS to run.")
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI
import TeatroUI

@main
struct TeatroApp: App {
  var body: some Scene {
    WindowGroup {
      CollectionBrowserView(service: .live)
    }
  }
}
#else
@main
struct TeatroApp {
  static func main() {}
}
#endif

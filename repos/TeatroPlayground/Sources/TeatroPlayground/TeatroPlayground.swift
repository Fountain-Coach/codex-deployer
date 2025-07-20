#if canImport(SwiftUI)
import SwiftUI
import TeatroPlaygroundUI
import Teatro

public typealias TViewBuilder = Teatro.ViewBuilder
public typealias SViewBuilder = SwiftUI.ViewBuilder

@main
struct TeatroPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            TeatroPlaygroundUI.ContentView()
        }
    }
}
#else
import Foundation

@main
struct TeatroPlaygroundApp {
    static func main() {
        print("TeatroPlayground stub - SwiftUI unavailable")
    }
}
#endif

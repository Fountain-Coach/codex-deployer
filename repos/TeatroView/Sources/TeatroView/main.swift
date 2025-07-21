import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Minimal entry point launching the Teatro views in a navigation layout.
@main
struct TeatroViewApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootView()
            }
        }
    }
}

/// Lists the available Teatro demo screens.
private struct RootView: View {
    private let service = try? TypesenseService()

    var body: some View {
        List {
            NavigationLink("Collections") {
                if let service { CollectionBrowserView(service: service) }
            }
            NavigationLink("Search") {
                if let service { SearchView(collection: "books", service: service) }
            }
            NavigationLink("Edit Schema") {
                if let service { SchemaEditorView(collection: "books", service: service) }
            }
        }
        .navigationTitle("TeatroView")
    }
}
#else
print("TeatroView requires SwiftUI and macOS to run.")
#endif

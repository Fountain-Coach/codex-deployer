#if canImport(SwiftUI)
import SwiftUI
import Teatro

public struct ContentView: View {
    @StateObject private var manager = DispatcherManager()

    public init() {}

    public var body: some View {
        TabView {
            DashboardView(manager: manager)
                .tabItem { Text("Dashboard") }
            QueueView()
                .tabItem { Text("Queue") }
            LogView(manager: manager)
                .tabItem { Text("Logs") }
            SettingsView()
                .tabItem { Text("Settings") }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

#if canImport(SwiftUI)
#Preview {
    ContentView()
}
#endif
#endif

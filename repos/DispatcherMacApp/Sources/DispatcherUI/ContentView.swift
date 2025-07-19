#if canImport(SwiftUI)
import SwiftUI
import Teatro

public typealias TViewBuilder = Teatro.ViewBuilder
public typealias SViewBuilder = SwiftUI.ViewBuilder

public struct ContentView: View {
    @StateObject private var manager = DispatcherManager()

    public init() {}

    public var body: some View {
        TabView {
            ZStack {
                DashboardView(manager: manager)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

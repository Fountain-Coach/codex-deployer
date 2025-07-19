#if canImport(SwiftUI)
import SwiftUI

/// Primary control panel showing dispatcher status and metrics.
public struct DashboardView: View {
    @ObservedObject var manager: DispatcherManager

    public init(manager: DispatcherManager) {
        self.manager = manager
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 20) {
                Button(manager.isRunning ? "Stop" : "Start") {
                    manager.isRunning ? manager.stop() : manager.start()
                }
                .keyboardShortcut(.defaultAction)

                Text(manager.isRunning ? "Running" : "Stopped")
                    .foregroundStyle(manager.isRunning ? .green : .red)
                Spacer()
                Text("Cycles: \(manager.cycleCount)")
                Text(manager.lastBuildResult)
            }
            if let last = manager.logs.last {
                Text(last).font(.footnote).foregroundStyle(.secondary)
            }
            TeatroRenderView(content: DispatcherPrompt())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

#Preview {
    DashboardView(manager: DispatcherManager())
}
#endif

#if canImport(SwiftUI)
import SwiftUI
import Teatro

public typealias TViewBuilder = Teatro.ViewBuilder
public typealias SViewBuilder = SwiftUI.ViewBuilder

/// Primary control panel showing dispatcher status and metrics.
public struct DashboardView: View {
    @ObservedObject var manager: ProcessManager
    @State private var command: String = ""

    public init(manager: ProcessManager) {
        self.manager = manager
    }

    public var body: some View {
        ZStack {
            card
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @SViewBuilder
    private var card: some View {
        VStack(spacing: 0) {
            header
            if let last = manager.logs.last {
                Text(last)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Divider().background(Color.gray.opacity(0.3))
            TeatroRenderView(content: ProcessPrompt())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.top, 20)
            TextField("Type command…", text: $command, onCommit: {
                manager.send(command)
                command = ""
            })
            .textFieldStyle(.roundedBorder)
        }
        .padding(16)
        .frame(minWidth: 700, minHeight: 500)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 4)
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(manager.isRunning ? Color.green : Color.red)
                .frame(width: 10, height: 10)
                .animation(.easeInOut(duration: 0.3), value: manager.isRunning)
            Button(manager.isRunning ? "Stop" : "Start") {
                manager.isRunning ? manager.stop() : manager.start()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.bordered)
            .tint(.blue)
            .controlSize(.small)
            Text(manager.isRunning ? "Running" : "Stopped")
                .foregroundStyle(manager.isRunning ? .green : .red)
            Spacer()
            Text("Cycles: \(manager.cycleCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(manager.lastBuildResult)
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    DashboardView(manager: ProcessManager())
}
#endif

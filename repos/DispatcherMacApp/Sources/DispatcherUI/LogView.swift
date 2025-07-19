#if canImport(SwiftUI)
import SwiftUI

/// Scrollable log output using a monospaced font.
public struct LogView: View {
    @ObservedObject var manager: DispatcherManager

    public init(manager: DispatcherManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(manager.logs.enumerated()), id: \.offset) { idx, line in
                        Text(line)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(idx)
                    }
                }
                .onChange(of: manager.logs.count) { _ in
                    if let last = manager.logs.indices.last {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }
        }
    }
}

#Preview {
    LogView(manager: DispatcherManager())
}
#endif

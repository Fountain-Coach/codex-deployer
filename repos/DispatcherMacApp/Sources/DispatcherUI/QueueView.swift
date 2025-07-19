#if canImport(SwiftUI)
import SwiftUI

/// Displays pending JSON patches from the feedback directory.
public struct QueueView: View {

    @State private var items: [QueueItem] = []
    var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    public init() {}

    public var body: some View {
        Table(items) {
            TableColumn("File") { item in
                Text(item.file)
            }
            TableColumn("Status") { item in
                Text(item.status)
            }
        }
        .onReceive(timer) { _ in refresh() }
        .onAppear { refresh() }
    }

    private func feedbackDir() -> URL {
        URL(fileURLWithPath: "/srv/deploy/feedback")
    }

    private func refresh() {
        let path = feedbackDir()
        let names = (try? FileManager.default.contentsOfDirectory(atPath: path.path)) ?? []
        items = names.sorted().map { QueueItem(file: $0) }
    }
}

#Preview {
    QueueView()
}
#endif

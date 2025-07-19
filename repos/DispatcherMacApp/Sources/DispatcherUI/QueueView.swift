#if canImport(SwiftUI)
import SwiftUI

/// Displays pending JSON patches from the feedback directory.
public struct QueueView: View {
    @State private var files: [String] = []
    var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        Table(of: String.self) {
            TableColumn("File") { item in
                Text(item)
            }
        } rows: {
            ForEach(files, id: \.self) { file in
                TableRow(file)
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
        let items = (try? FileManager.default.contentsOfDirectory(atPath: path.path)) ?? []
        files = items.sorted()
    }
}

#Preview {
    QueueView()
}
#endif

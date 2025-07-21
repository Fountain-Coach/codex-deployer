import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Displays the list of collections returned by `TypesenseService`.
@MainActor
public struct CollectionBrowserView: View {
    private let service: TypesenseService?
    @State private var names: [String]
    @State private var errorMessage: String?

    /// Runtime initializer using the Typesense service.
    public init(service: TypesenseService) {
        self.service = service
        self._names = State(initialValue: [])
    }

    /// Preview initializer using static names.
    public init(names: [String]) {
        self.service = nil
        self._names = State(initialValue: names)
    }

    public var body: some View {
        ScrollView {
            Text(scene.render())
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .task { await loadIfNeeded() }
    }

    @MainActor
    private func loadIfNeeded() async {
        guard let service else { return }
        do {
            let collections = try await service.listCollections()
            names = collections.map { $0.name }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var scene: Stage {
        Stage(title: "Collections") {
            Text(renderedNames())
        }
    }

    private func renderedNames() -> String {
        if let msg = errorMessage { return msg }
        guard !names.isEmpty else { return "No collections" }
        return names.map { "• \($0)" }.joined(separator: "\n")
    }
}

#if DEBUG
struct CollectionBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionBrowserView(names: ["books", "articles"])
    }
}
#endif
#endif

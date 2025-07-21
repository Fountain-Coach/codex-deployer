import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Performs a simple search against a Typesense collection and renders results.
@MainActor
public struct SearchView: View {
    private let service: TypesenseService?
    private let collection: String
    @State private var query: String = ""
    @State private var results: [String]
    @State private var errorMessage: String?

    /// Runtime initializer using the service.
    public init(collection: String, service: TypesenseService) {
        self.collection = collection
        self.service = service
        self._results = State(initialValue: [])
    }

    /// Preview initializer with static results.
    public init(collection: String, results: [String]) {
        self.collection = collection
        self.service = nil
        self._results = State(initialValue: results)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Search", text: $query)
                    .textFieldStyle(.roundedBorder)
                Button("Go") { Task { await performSearch() } }
            }
            .padding(.bottom)
            ScrollView {
                Text(scene.render())
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
        }
        .task { if results.isEmpty { await performSearch() } }
    }

    @MainActor
    private func performSearch() async {
        guard let service else { return }
        do {
            let resp = try await service.search(collection: collection, q: query, queryBy: "*")
            results = resp.hits.map { String(describing: $0.document) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var scene: Stage {
        Stage(title: "Results") {
            Text(renderedResults())
        }
    }

    private func renderedResults() -> String {
        if let msg = errorMessage { return msg }
        guard !results.isEmpty else { return "No results" }
        return results.map { "• \($0)" }.joined(separator: "\n")
    }
}

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(collection: "books", results: ["Result A", "Result B"])
    }
}
#endif
#endif

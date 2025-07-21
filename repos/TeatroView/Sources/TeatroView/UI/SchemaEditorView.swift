import Teatro
#if canImport(SwiftUI)
import SwiftUI
import TypesenseClient

/// Edits a collection schema using raw JSON and sends updates via `TypesenseService`.
@MainActor
public struct SchemaEditorView: View {
    @MainActor private let service: TypesenseService?
    private let collection: String
    @State private var text: String
    @State private var message: String?

    /// Runtime initializer.
    public init(collection: String, service: TypesenseService) {
        self.collection = collection
        self.service = service
        self._text = State(initialValue: "{}")
    }

    /// Preview initializer with static JSON.
    public init(collection: String, text: String) {
        self.collection = collection
        self.service = nil
        self._text = State(initialValue: text)
    }

    /// Preview initializer using a schema object.
    public init(schema: CollectionUpdateSchema) {
        self.collection = schema.name
        self.service = nil
        if let data = try? JSONEncoder().encode(schema),
           let json = String(data: data, encoding: .utf8) {
            self._text = State(initialValue: json)
        } else {
            self._text = State(initialValue: "{}")
        }
    }

    public var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray)
                .frame(height: 200)
            Button("Update") { Task { await submit() } }
            Text(scene.render())
                .font(.system(.body, design: .monospaced))
                .padding(.top)
        }
    }

    @MainActor
    private func submit() async {
        guard let service else { return }
        guard let data = text.data(using: .utf8) else { return }
        do {
            let schema = try JSONDecoder().decode(CollectionUpdateSchema.self, from: data)
            let resp = try await service.updateSchema(collection: collection, schema: schema)
            message = "Updated with \(resp.fields.count) fields"
        } catch {
            message = error.localizedDescription
        }
    }

    private var scene: Stage {
        Stage(title: "Status") {
            Text(message ?? "")
        }
    }
}

#if DEBUG
#Preview {
    SchemaEditorView(schema: CollectionUpdateSchema(name: "test", fields: []))
}
#endif
#endif

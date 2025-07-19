#if canImport(SwiftUI)
import SwiftUI

/// Edit dispatcher.env variables.
public struct SettingsView: View {
    @State private var values: [String: String] = [:]

    public init() {}

    public var body: some View {
        Form {
            ForEach(values.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key).frame(width: 200, alignment: .trailing)
                    TextField("", text: Binding(
                        get: { values[key] ?? "" },
                        set: { values[key] = $0 }
                    ))
                }
            }
            Button("Save") { save() }
        }
        .padding()
        .onAppear { load() }
    }

    private var fileURL: URL {
        URL(fileURLWithPath: "/srv/deploy/dispatcher.env")
    }

    private func load() {
        guard let data = try? String(contentsOf: fileURL) else { return }
        var dict: [String: String] = [:]
        for line in data.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") || trimmed.isEmpty { continue }
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                dict[String(parts[0])] = String(parts[1])
            }
        }
        values = dict
    }

    private func save() {
        let content = values.keys.sorted().map { "\($0)=\(values[$0] ?? "")" }.joined(separator: "\n")
        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

#Preview {
    SettingsView()
}
#endif

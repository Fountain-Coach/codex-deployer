import Teatro
#if canImport(SwiftUI)
import SwiftUI

/// Displays raw Typesense hits for a given search.
@MainActor
public struct RetrievalInspectorView: View {
    public let hits: [String]

    public init(hits: [String]) {
        self.hits = hits
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(hits, id: \.self) { hit in
                    Text(hit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding()
        }
    }
}
#endif

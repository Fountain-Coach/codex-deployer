import Teatro
#if canImport(SwiftUI)
import SwiftUI

public struct PromptHistoryItem: Identifiable {
    public let id = UUID()
    public let text: String
    public let isError: Bool
    public init(text: String, isError: Bool = false) {
        self.text = text
        self.isError = isError
    }
}

/// Timeline of prompts, tool calls and errors with ability to fork a new chat.
@MainActor
public struct PromptHistoryView: View {
    @State private var items: [PromptHistoryItem]

    /// Runtime initializer
    public init(items: [PromptHistoryItem] = []) {
        self._items = State(initialValue: items)
    }

    public var body: some View {
        List(items) { item in
            HStack {
                Circle()
                    .fill(item.isError ? Color.red : Color.blue)
                    .frame(width: 8, height: 8)
                Text(item.text)
                Spacer()
                Button("Fork") { fork(item) }
                    .buttonStyle(.borderless)
            }
        }
    }

    private func fork(_ item: PromptHistoryItem) {
        // Placeholder hook for host applications to start a new chat tab.
    }
}

#if DEBUG
public struct PromptHistoryView_Previews: PreviewProvider {
    public static var previews: some View {
        PromptHistoryView(items: [
            PromptHistoryItem(text: "User: Search books"),
            PromptHistoryItem(text: "LLM: Found 3 results"),
            PromptHistoryItem(text: "Error: timeout", isError: true)
        ])
    }
}
#endif
#endif

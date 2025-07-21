import Teatro
#if canImport(SwiftUI)
import SwiftUI

public struct ChatMessage: Identifiable {
    public let id = UUID()
    public let text: String
    public let isUser: Bool
}

/// Basic chat view that streams prompts to the LLM Gateway.
@MainActor
public struct ChatWorkspaceView: View {
    private let llm: LLMService
    @State private var prompt: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading: Bool = false

    public init(llm: LLMService = .init()) {
        self.llm = llm
    }

    public var body: some View {
        VStack {
            List(messages) { msg in
                HStack(alignment: .top) {
                    Text(msg.isUser ? "You:" : "LLM:")
                        .bold()
                    Text(msg.text)
                }
            }
            HStack {
                TextField("Prompt", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                if isLoading { ProgressView() }
                Button("Send") { Task { await send() } }
            }
            .padding()
        }
    }

    private func send() async {
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        prompt = ""
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true
        do {
            let reply = try await llm.chat(text)
            messages.append(ChatMessage(text: reply, isUser: false))
        } catch {
            messages.append(ChatMessage(text: error.localizedDescription, isUser: false))
        }
        isLoading = false
    }
}

#if DEBUG
public struct ChatWorkspaceView_Previews: PreviewProvider {
    public static var previews: some View {
        ChatWorkspaceView()
    }
}
#endif
#endif

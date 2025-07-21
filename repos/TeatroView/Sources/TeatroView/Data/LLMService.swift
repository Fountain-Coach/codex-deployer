import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Minimal client for the LLM Gateway used by `ChatWorkspaceView`.
@MainActor
public struct LLMService {
    private let baseURL: URL?

    public init() {
        if let urlString = ProcessInfo.processInfo.environment["LLM_GATEWAY_URL"],
           let url = URL(string: urlString) {
            self.baseURL = url
        } else {
            self.baseURL = nil
        }
    }

    /// Send the user's prompt to the gateway and return the streamed reply.
    public func chat(_ prompt: String) async throws -> String {
        guard let baseURL else { return "Plan for: \(prompt)" }

        var req = URLRequest(url: baseURL.appendingPathComponent("chat"))
        req.httpMethod = "POST"
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, _) = try await URLSession.shared.data(for: req)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

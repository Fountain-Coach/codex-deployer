import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Client for the LLM Gateway. When `LLM_GATEWAY_URL` is unset it returns
/// a stubbed response for offline tests. See `docs/environment_variables.md`.
struct LLMGatewayClient {
    private let baseURL: URL?

    init() {
        if let urlString = ProcessInfo.processInfo.environment["LLM_GATEWAY_URL"],
           let url = URL(string: urlString) {
            self.baseURL = url
        } else {
            self.baseURL = nil
        }
    }

    func chat(objective: String) async throws -> String {
        guard let baseURL else {
            // Offline fallback used by integration tests
            return "Plan for: \(objective)"
        }

        var req = URLRequest(url: baseURL.appendingPathComponent("chat"))
        req.httpMethod = "POST"
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": objective]]
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

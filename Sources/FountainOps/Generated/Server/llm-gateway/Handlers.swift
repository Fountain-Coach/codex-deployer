import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Handlers {
    let session: URLSession
    let cotLogURL: URL?
    public init(session: URLSession = .shared, cotLogURL: URL? = nil) {
        self.session = session
        self.cotLogURL = cotLogURL
    }

    // Minimal stub simulating a consult handler that queries an LLM endpoint and
    // returns a SecurityDecision reflecting the first choice message content.
    public func sentinelconsult(_ request: HTTPRequest, body: SecurityCheckRequest) async throws -> HTTPResponse {
        // Compose a trivial request to any URL; tests inject a URLProtocol stub,
        // so the actual endpoint does not matter.
        let url = URL(string: "https://example.invalid/llm/chat")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(body)
        _ = try await session.data(for: urlRequest)

        // The StubProtocol returns a JSON like:
        // {"choices":[{"message":{"content":"allow|deny|escalate"}}]}
        let (data, _) = try await session.data(for: urlRequest)
        let decision = try Self.parseDecision(from: data)
        let respBody = try JSONEncoder().encode(SecurityDecision(decision: decision))
        return HTTPResponse(status: 200, body: respBody)
    }

    // Minimal CoT endpoint handler used in tests.
    public func chatcot(_ request: HTTPRequest, body: Any?) async throws -> HTTPResponse {
        guard let cotLogURL else { return HTTPResponse(status: 404) }
        // Path expected: /chat/{id}/cot
        let parts = request.path.split(separator: "/").map(String.init)
        guard parts.count >= 3 else { return HTTPResponse(status: 400) }
        let chatID = parts[1]
        let role = request.headers["X-User-Role"] ?? "user"
        let content = try String(contentsOf: cotLogURL, encoding: .utf8)
        let lines = content.split(separator: "\n")
        var cot: String?
        for line in lines {
            if let data = line.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = obj["id"] as? String, id == chatID,
               let c = obj["cot"] as? String {
                cot = c; break
            }
        }
        let responseData: Data
        if role == "developer" {
            // Redact middle tokens: first/last preserved.
            let words = (cot ?? "").split(separator: " ")
            if words.count >= 2 {
                let redacted = [words.first!, "[REDACTED]", words.last!].joined(separator: " ")
                responseData = try JSONSerialization.data(withJSONObject: ["cot": redacted])
            } else {
                responseData = try JSONSerialization.data(withJSONObject: ["cot": cot ?? ""])
            }
        } else {
            // Return a simple summary placeholder for non-developers.
            responseData = try JSONSerialization.data(withJSONObject: ["cot_summary": (cot ?? "").prefix(8) + "..."])
        }
        return HTTPResponse(status: 200, body: responseData)
    }

    private static func parseDecision(from data: Data) throws -> String {
        struct ChatResponse: Decodable {
            struct Choice: Decodable { struct Message: Decodable { let content: String }; let message: Message }
            let choices: [Choice]
        }
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.choices.first?.message.content ?? "escalate"
    }
}

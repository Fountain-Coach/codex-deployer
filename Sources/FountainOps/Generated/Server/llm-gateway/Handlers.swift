import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ServiceShared

public struct Handlers {
    public init() {}
    public func metricsMetricsGet(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        let text = await PrometheusAdapter.shared.exposition()
        return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data(text.utf8))
    }
    public func sentinelconsult(_ request: HTTPRequest, body: SecurityCheckRequest?) async throws -> HTTPResponse {
        guard let body else { return HTTPResponse(status: 400) }
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return HTTPResponse(status: 500)
        }
        let base = ProcessInfo.processInfo.environment["OPENAI_API_BASE"] ?? "https://api.openai.com/v1/chat/completions"
        var payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are security_sentinel. Respond with allow, deny, or escalate."],
                ["role": "user", "content": body.summary]
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: payload)
        var urlRequest = URLRequest(url: URL(string: base)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let (respData, _) = try await URLSession.shared.data(for: urlRequest)
        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }
        let decisionStr = try JSONDecoder().decode(OpenAIResponse.self, from: respData).choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "deny"
        let decision = SecurityDecision(decision: decisionStr)
        let bodyData = try JSONEncoder().encode(decision)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: bodyData)
    }
    public func chatwithobjective(_ request: HTTPRequest, body: ChatRequest?) async throws -> HTTPResponse {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return HTTPResponse(status: 500)
        }
        let base = ProcessInfo.processInfo.environment["OPENAI_API_BASE"] ?? "https://api.openai.com/v1/chat/completions"
        var urlRequest = URLRequest(url: URL(string: base)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return HTTPResponse(body: data)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

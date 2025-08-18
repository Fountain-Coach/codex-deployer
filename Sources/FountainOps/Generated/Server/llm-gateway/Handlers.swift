import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ServiceShared

public struct Handlers {
    private let cotLogURL: URL
    public init(cotLogURL: URL = URL(fileURLWithPath: "logs/cot.log")) {
        self.cotLogURL = cotLogURL
    }
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
        let payload: [String: Any] = [
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

    public func chatcot(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        let parts = request.path.split(separator: "/")
        guard parts.count == 3 else { return HTTPResponse(status: 404) }
        let id = String(parts[1])
        guard let role = request.headers["X-User-Role"] else { return HTTPResponse(status: 401) }
        guard let text = try? String(contentsOf: cotLogURL, encoding: .utf8) else {
            return HTTPResponse(status: 404)
        }
        var found: Any?
        text.enumerateLines { line, stop in
            if let obj = try? JSONSerialization.jsonObject(with: Data(line.utf8)) as? [String: Any],
               let lineId = obj["id"] as? String, lineId == id {
                found = obj["cot"]
                stop = true
            }
        }
        guard let cot = found else { return HTTPResponse(status: 404) }
        let sanitized = sanitize(cot)
        let payload: [String: Any]
        if ["developer", "auditor"].contains(role) {
            payload = ["id": id, "cot": sanitized]
        } else {
            let summary = String(describing: sanitized)
            let truncated = summary.count > 80 ? String(summary.prefix(80)) : summary
            payload = ["id": id, "cot_summary": truncated]
        }
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: bodyData)
    }

    private func sanitize(_ value: Any) -> Any {
        if let str = value as? String {
            return sanitizeString(str)
        } else if let arr = value as? [Any] {
            return arr.map { sanitize($0) }
        } else if let dict = value as? [String: Any] {
            var result: [String: Any] = [:]
            for (k, v) in dict { result[k] = sanitize(v) }
            return result
        } else {
            return value
        }
    }

    private func sanitizeString(_ input: String) -> String {
        var output = input
        let patterns = ["secret", "password", "api_key"]
        for p in patterns {
            output = output.replacingOccurrences(of: p, with: "[REDACTED]", options: .caseInsensitive)
        }
        return output
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

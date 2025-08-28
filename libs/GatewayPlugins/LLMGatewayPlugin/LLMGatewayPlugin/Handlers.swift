import Foundation
import FountainRuntime

/// Collection of request handlers used by ``LLMGatewayPlugin``.
public struct Handlers: Sendable {
    /// Location of the CoT log file, if any.
    let cotLogURL: URL?

    public init(cotLogURL: URL? = nil) {
        self.cotLogURL = cotLogURL
    }

    /// Simple sentinel consult handler that performs trivial
    /// decision logic on the provided summary text.
    public func sentinelConsult(_ request: HTTPRequest, body: SecurityCheckRequest) async throws -> HTTPResponse {
        let summary = body.summary.lowercased()
        let decision: String
        if summary.contains("escalate") {
            decision = "escalate"
        } else if summary.contains("delete") || summary.contains("deny") || summary.contains("danger") {
            decision = "deny"
        } else {
            decision = "allow"
        }
        let respBody = try JSONEncoder().encode(SecurityDecision(decision: decision))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: respBody)
    }

    /// Handler that retrieves CoT logs for a chat and applies
    /// basic role based redaction.
    public func chatCoT(_ request: HTTPRequest, chatID: String) async throws -> HTTPResponse {
        guard let cotLogURL else { return HTTPResponse(status: 404) }
        let role = request.headers["X-User-Role"] ?? "user"
        let content = (try? String(contentsOf: cotLogURL, encoding: .utf8)) ?? ""
        var cot: String?
        for line in content.split(separator: "\n") {
            if let data = line.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = obj["id"] as? String, id == chatID,
               let c = obj["cot"] as? String {
                cot = c
                break
            }
        }
        let responseData: Data
        if role == "developer" {
            let words = (cot ?? "").split(separator: " ")
            if words.count >= 2 {
                let redacted = [words.first!, "[REDACTED]", words.last!].joined(separator: " ")
                responseData = try JSONSerialization.data(withJSONObject: ["cot": redacted])
            } else {
                responseData = try JSONSerialization.data(withJSONObject: ["cot": cot ?? ""])
            }
        } else {
            let summary = String((cot ?? "").prefix(8)) + "..."
            responseData = try JSONSerialization.data(withJSONObject: ["cot_summary": summary])
        }
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: responseData)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation
import FountainCodex

/// Actor housing Security Sentinel handlers.
public actor Handlers {
    public init() {}

    /// Consults the security sentinel and returns a decision.
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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

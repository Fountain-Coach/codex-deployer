import Foundation

/// Request model sent to Security Sentinel for evaluation.
public struct SecurityCheckRequest: Codable, Sendable {
    public let summary: String
    public let user: String
    public let resources: [String]
    public init(summary: String, user: String, resources: [String]) {
        self.summary = summary
        self.user = user
        self.resources = resources
    }
}

/// Response decision returned by Security Sentinel.
public struct SecurityDecision: Codable, Sendable {
    public let decision: String
    public init(decision: String) {
        self.decision = decision
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

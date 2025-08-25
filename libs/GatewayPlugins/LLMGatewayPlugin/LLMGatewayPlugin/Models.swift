import Foundation

/// Request sent to the sentinel consult endpoint.
public struct SecurityCheckRequest: Codable {
    public let summary: String
    public let user: String
    public let resources: [String]
    public init(summary: String, user: String, resources: [String]) {
        self.summary = summary
        self.user = user
        self.resources = resources
    }
}

/// Response returned by the sentinel containing its decision.
public struct SecurityDecision: Codable {
    public let decision: String
    public init(decision: String) { self.decision = decision }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

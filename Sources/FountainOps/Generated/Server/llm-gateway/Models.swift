import Foundation

public struct SecurityCheckRequest: Codable {
    public let resources: [String]
    public let summary: String
    public let user: String
    public init(resources: [String], summary: String, user: String) {
        self.resources = resources
        self.summary = summary
        self.user = user
    }
}

public struct SecurityDecision: Codable {
    public let decision: String
    public init(decision: String) { self.decision = decision }
}


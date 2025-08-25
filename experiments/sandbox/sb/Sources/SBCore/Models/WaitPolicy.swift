import Foundation

public struct WaitPolicy: Codable, Sendable {
    public enum Strategy: String, Codable, Sendable {
        case domContentLoaded
        case networkIdle
        case selector
    }

    public var strategy: Strategy
    public var networkIdleMs: Int?
    public var selector: String?
    public var maxWaitMs: Int?

    public init(strategy: Strategy, networkIdleMs: Int? = nil, selector: String? = nil, maxWaitMs: Int? = nil) {
        self.strategy = strategy
        self.networkIdleMs = networkIdleMs
        self.selector = selector
        self.maxWaitMs = maxWaitMs
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

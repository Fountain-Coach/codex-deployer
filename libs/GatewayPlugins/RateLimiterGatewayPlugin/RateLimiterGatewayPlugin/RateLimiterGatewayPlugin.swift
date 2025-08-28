import Foundation
import FountainRuntime

/// Plugin implementing a token bucket rate limiter with per-client buckets.
public struct RateLimiterGatewayPlugin: Sendable {
    public let router: Router
    private let handlers: Handlers

    public init(defaultLimit: Int = 60) {
        let h = Handlers(defaultLimit: defaultLimit)
        self.handlers = h
        self.router = Router(handlers: h)
    }

    public func allow(routeId: String, clientId: String, limitPerMinute: Int?) async -> Bool {
        await handlers.allow(routeId: routeId, clientId: clientId, limitPerMinute: limitPerMinute)
    }

    public func stats() async -> (allowed: Int, throttled: Int) {
        await handlers.stats()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

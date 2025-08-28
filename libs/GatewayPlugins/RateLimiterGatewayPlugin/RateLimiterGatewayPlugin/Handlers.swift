import Foundation
import FountainRuntime

/// Collection of handlers for rate limiter gateway endpoints.
public actor Handlers {
    private struct Bucket { var tokens: Double; var lastRefill: TimeInterval; let capacity: Double; let rate: Double }
    private var buckets: [String: Bucket] = [:]
    private var allowed = 0
    private var throttled = 0
    private let defaultLimit: Int

    public init(defaultLimit: Int = 60) {
        self.defaultLimit = defaultLimit
    }

    /// Checks and consumes a token for the given route and client.
    public func allow(routeId: String, clientId: String, limitPerMinute: Int?) -> Bool {
        let limit = limitPerMinute ?? defaultLimit
        if limit <= 0 {
            allowed += 1
            Task { await DNSMetrics.shared.recordRateLimit(allowed: true) }
            return true
        }
        let key = "\(routeId)#\(clientId)"
        let ratePerSecond = Double(limit) / 60.0
        let now = Date().timeIntervalSince1970
        var bucket = buckets[key] ?? Bucket(tokens: Double(limit), lastRefill: now, capacity: Double(limit), rate: ratePerSecond)
        let elapsed = max(0, now - bucket.lastRefill)
        bucket.tokens = min(bucket.capacity, bucket.tokens + elapsed * bucket.rate)
        bucket.lastRefill = now
        if bucket.tokens >= 1.0 {
            bucket.tokens -= 1.0
            buckets[key] = bucket
            allowed += 1
            Task { await DNSMetrics.shared.recordRateLimit(allowed: true) }
            return true
        }
        buckets[key] = bucket
        throttled += 1
        Task { await DNSMetrics.shared.recordRateLimit(allowed: false) }
        return false
    }

    /// Returns accumulated allowed and throttled counts.
    public func stats() -> (allowed: Int, throttled: Int) { (allowed, throttled) }

    /// Handler for rate limit checks.
    public func rateLimitCheck(_ request: HTTPRequest, body: RateLimitCheckRequest?) async throws -> HTTPResponse {
        guard let body else { return HTTPResponse(status: 400) }
        let permitted = allow(routeId: body.routeId, clientId: body.clientId, limitPerMinute: body.limitPerMinute)
        let resp = RateLimitCheckResponse(allowed: permitted)
        let data = try JSONEncoder().encode(resp)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    /// Handler returning aggregated statistics.
    public func rateLimitStats(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        let (allowed, throttled) = stats()
        let resp = RateLimitStatsResponse(allowed: allowed, throttled: throttled)
        let data = try JSONEncoder().encode(resp)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

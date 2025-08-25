import Foundation
import FountainCodex

/// Plugin implementing a token bucket rate limiter with per-client buckets.
public final actor RateLimiterPlugin: GatewayPlugin {
    private struct Bucket { var tokens: Double; var lastRefill: TimeInterval; let capacity: Double; let rate: Double }
    private var buckets: [String: Bucket] = [:]
    private var allowed = 0
    private var throttled = 0
    private let defaultLimit: Int

    /// Creates a new rate limiter plugin.
    /// - Parameter defaultLimit: Fallback limit per minute when a route lacks an explicit limit.
    public init(defaultLimit: Int = 60) {
        self.defaultLimit = defaultLimit
    }

    /// Returns accumulated allowed and throttled counts.
    public func stats() -> (allowed: Int, throttled: Int) { (allowed, throttled) }

    /// Checks and consumes a token for the given route and client.
    /// - Parameters:
    ///   - routeId: Identifier of the route being accessed.
    ///   - clientId: Authenticated subject or API key. "anonymous" when unavailable.
    ///   - limitPerMinute: Optional override limit for this specific route.
    /// - Returns: ``true`` if the request should proceed, ``false`` when throttled.
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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

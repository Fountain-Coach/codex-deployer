import Foundation

public actor DNSMetrics {
    public static let shared = DNSMetrics()

    private var queries = 0
    private var hits = 0
    private var misses = 0
    private var rateLimitAllowed = 0
    private var rateLimitThrottled = 0
    private var queriesByType: [String: Int] = [:]
    private var hitsByType: [String: Int] = [:]

    public func record(query name: String, type: String, hit: Bool) {
        queries += 1
        queriesByType[type, default: 0] += 1
        if hit {
            hits += 1
            hitsByType[type, default: 0] += 1
        } else {
            misses += 1
        }
    }

    public func recordRateLimit(allowed: Bool) {
        if allowed {
            rateLimitAllowed += 1
        } else {
            rateLimitThrottled += 1
        }
    }

    public func exposition() -> String {
        var lines = [
            "dns_queries_total \(queries)",
            "dns_hits_total \(hits)",
            "dns_misses_total \(misses)",
            "gateway_rate_limit_allowed_total \(rateLimitAllowed)",
            "gateway_rate_limit_throttled_total \(rateLimitThrottled)"
        ]
        for key in queriesByType.keys.sorted() {
            lines.append("dns_queries_type_\(key)_total \(queriesByType[key] ?? 0)")
            lines.append("dns_hits_type_\(key)_total \(hitsByType[key] ?? 0)")
        }
        return lines.joined(separator: "\n")
    }

    public func reset() {
        queries = 0
        hits = 0
        misses = 0
        rateLimitAllowed = 0
        rateLimitThrottled = 0
        queriesByType = [:]
        hitsByType = [:]
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation

public actor DNSMetrics {
    public static let shared = DNSMetrics()

    private var queries = 0
    private var hits = 0
    private var misses = 0

    public func record(query name: String, hit: Bool) {
        queries += 1
        if hit {
            hits += 1
        } else {
            misses += 1
        }
    }

    public func exposition() -> String {
        """
        dns_queries_total \(queries)
        dns_hits_total \(hits)
        dns_misses_total \(misses)
        """
    }

    public func reset() {
        queries = 0
        hits = 0
        misses = 0
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

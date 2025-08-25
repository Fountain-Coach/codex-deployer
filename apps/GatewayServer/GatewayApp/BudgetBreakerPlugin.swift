import Foundation
import FountainCodex

/// Plugin enforcing per-user request budgets with circuit breakers and health-based shedding.
public final actor BudgetBreakerPlugin: GatewayPlugin {
    private struct Bucket { var tokens: Double; var last: TimeInterval; let capacity: Double; let rate: Double }
    private struct Breaker { var failures: Int; var retryAt: TimeInterval }
    private var buckets: [String: Bucket] = [:]
    private var breakers: [String: Breaker] = [:]
    private var healthy = true
    private var allowed = 0
    private var throttled = 0
    private let defaultBudget: Int
    private let failureThreshold: Int
    private let baseBackoff: TimeInterval

    /// Creates a new resilience plugin.
    /// - Parameters:
    ///   - defaultBudget: Default requests per minute for each user/route.
    ///   - failureThreshold: Consecutive failures before opening the circuit.
    ///   - baseBackoff: Initial backoff delay in seconds once the circuit opens.
    public init(defaultBudget: Int = 60, failureThreshold: Int = 3, baseBackoff: TimeInterval = 1.0) {
        self.defaultBudget = defaultBudget
        self.failureThreshold = failureThreshold
        self.baseBackoff = baseBackoff
    }

    /// Updates health state based on external autoscaling or health signals.
    public func updateHealth(isHealthy: Bool) { self.healthy = isHealthy }

    /// Returns accumulated allowed and throttled counts.
    public func stats() -> (allowed: Int, throttled: Int) { (allowed, throttled) }

    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        guard healthy else {
            throttled += 1
            Task { await DNSMetrics.shared.recordRateLimit(allowed: false) }
            throw ServiceUnavailableError()
        }
        let key = keyFor(request)
        let now = Date().timeIntervalSince1970
        // Circuit breaker check
        if let breaker = breakers[key], now < breaker.retryAt {
            throttled += 1
            Task { await DNSMetrics.shared.recordRateLimit(allowed: false) }
            throw ServiceUnavailableError()
        }
        // Token bucket budget check
        let limit = defaultBudget
        let rate = Double(limit) / 60.0
        var bucket = buckets[key] ?? Bucket(tokens: Double(limit), last: now, capacity: Double(limit), rate: rate)
        let elapsed = max(0, now - bucket.last)
        bucket.tokens = min(bucket.capacity, bucket.tokens + elapsed * bucket.rate)
        bucket.last = now
        if bucket.tokens >= 1.0 {
            bucket.tokens -= 1.0
            buckets[key] = bucket
            allowed += 1
            Task { await DNSMetrics.shared.recordRateLimit(allowed: true) }
            return request
        }
        buckets[key] = bucket
        throttled += 1
        Task { await DNSMetrics.shared.recordRateLimit(allowed: false) }
        throw TooManyRequestsError()
    }

    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        let key = keyFor(request)
        if response.status >= 500 {
            var breaker = breakers[key] ?? Breaker(failures: 0, retryAt: 0)
            breaker.failures += 1
            if breaker.failures >= failureThreshold {
                let delay = baseBackoff * pow(2, Double(breaker.failures - failureThreshold))
                breaker.retryAt = Date().timeIntervalSince1970 + delay
                breaker.failures = 0
            }
            breakers[key] = breaker
        } else {
            breakers[key] = nil
        }
        return response
    }

    private func keyFor(_ request: HTTPRequest) -> String {
        var clientId = "anonymous"
        if let auth = request.headers["Authorization"], auth.hasPrefix("Bearer ") {
            let token = String(auth.dropFirst(7))
            let store = CredentialStore()
            clientId = store.subject(for: token) ?? clientId
        }
        return "\(request.path)#\(clientId)"
    }
}

/// Error thrown when request budgets are exhausted.
public struct TooManyRequestsError: Error {}
/// Error thrown when load shedding or circuit breaking denies a request.
public struct ServiceUnavailableError: Error {}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

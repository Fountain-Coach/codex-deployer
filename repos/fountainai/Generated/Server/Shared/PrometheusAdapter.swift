import Foundation

public actor PrometheusAdapter {
    public static let shared = PrometheusAdapter()

    private var counters: [String:Int] = [:]
    private var durations: [String:(count: Int, total: Double)] = [:]
    private var successes: [String:Int] = [:]
    private var failures: [String:Int] = [:]

    public init() {}

    private func key(service: String, path: String) -> String {
        "{service=\"\(service)\",path=\"\(path)\"}"
    }

    public func record(service: String, path: String) {
        let k = key(service: service, path: path)
        counters[k, default: 0] += 1
    }

    public func recordResult(service: String, path: String, success: Bool) {
        let k = key(service: service, path: path)
        if success {
            successes[k, default: 0] += 1
        } else {
            failures[k, default: 0] += 1
        }
    }

    public func recordDuration(service: String, path: String, duration: Double) {
        let k = key(service: service, path: path)
        var entry = durations[k] ?? (0, 0)
        entry.count += 1
        entry.total += duration
        durations[k] = entry
    }

    public func exposition() -> String {
        var lines = counters.map { "requests_total\($0.key) \($0.value)" }
        for (k, v) in durations {
            lines.append("request_duration_seconds_sum\(k) \(v.total)")
            lines.append("request_duration_seconds_count\(k) \(v.count)")
        }
        for (k, v) in successes {
            lines.append("invocation_success_total\(k) \(v)")
        }
        for (k, v) in failures {
            lines.append("invocation_failure_total\(k) \(v)")
        }
        return lines.sorted().joined(separator: "\n") + "\n"
    }
}

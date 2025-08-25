import Foundation
import FountainCodex

/// Plugin that logs chain-of-thought responses when requested.
/// When a `/chat` request includes `include_cot: true`, any `cot`
/// field returned in the response body is appended to a log file.
public struct CoTLogger: GatewayPlugin {
    private let logURL: URL
    private let sentinel: SecuritySentinelPlugin?
    private let patterns: [String]

    /// Creates a new logger.
    /// - Parameters:
    ///   - logURL: Destination file for captured reasoning steps.
    ///   - sentinel: Optional security sentinel used to vet risky reasoning.
    ///   - patterns: Keywords that trigger a sentinel consult when present in the CoT.
    public init(logURL: URL = URL(fileURLWithPath: "logs/cot.log"),
                sentinel: SecuritySentinelPlugin? = nil,
                patterns: [String] = ["delete", "rm", "destroy", "truncate"]) {
        self.logURL = logURL
        self.sentinel = sentinel
        self.patterns = patterns
    }

    /// Saves chain-of-thought steps when present and requested.
    /// - Parameters:
    ///   - response: Response returned from the routed handler.
    ///   - request: Original request that may contain the `include_cot` flag.
    /// - Returns: The unmodified response.
    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        guard request.path == "/chat" else { return response }
        guard let reqJSON = try? JSONSerialization.jsonObject(with: request.body) as? [String: Any],
              (reqJSON["include_cot"] as? Bool) == true else { return response }
        guard let respJSON = try? JSONSerialization.jsonObject(with: response.body) as? [String: Any],
              let cot = respJSON["cot"],
              let id = respJSON["id"] as? String else { return response }
        var entry: [String: Any] = ["id": id, "cot": sanitize(cot)]

        if isRisky(cot), let sentinel = sentinel {
            let user = request.headers["X-User"] ?? "anonymous"
            let summary = String(describing: cot)
            if let decision = try? await sentinel.consult(summary: summary, user: user, resources: [summary]) {
                entry["sentinel_decision"] = decision.rawValue
            }
        }

        guard let data = try? JSONSerialization.data(withJSONObject: entry) else { return response }
        do {
            let dir = logURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: logURL.path) {
                _ = FileManager.default.createFile(atPath: logURL.path, contents: nil)
            }
            let handle = try FileHandle(forWritingTo: logURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
            try handle.write(contentsOf: Data("\n".utf8))
        } catch {
            // ignore logging errors
        }
        return response
    }

    private func sanitize(_ value: Any) -> Any {
        if let str = value as? String {
            return sanitizeString(str)
        } else if let arr = value as? [Any] {
            return arr.map { sanitize($0) }
        } else if let dict = value as? [String: Any] {
            var result: [String: Any] = [:]
            for (k, v) in dict { result[k] = sanitize(v) }
            return result
        } else {
            return value
        }
    }

    private func sanitizeString(_ input: String) -> String {
        var output = input
        let patterns = ["secret", "password", "api_key"]
        for p in patterns {
            output = output.replacingOccurrences(of: p, with: "[REDACTED]", options: .caseInsensitive)
        }
        return output
    }

    private func isRisky(_ value: Any) -> Bool {
        let text = String(describing: value).lowercased()
        return patterns.contains { text.contains($0) }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


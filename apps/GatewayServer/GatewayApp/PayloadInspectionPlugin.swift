import Foundation
import FountainCodex

/// Plugin that inspects request and response bodies for forbidden content.
/// Supports allow/deny lists and transformation rules to sanitize data.
/// Violations are recorded to an audit log.
public struct PayloadInspectionPlugin: GatewayPlugin {
    /// Patterns that bypass inspection when matched.
    public let allowList: [String]
    /// Patterns that trigger inspection when matched.
    public let denyList: [String]
    /// Mapping of deny patterns to replacement text.
    public let transformations: [String: String]
    private let logURL: URL

    /// Creates a new plugin instance.
    /// - Parameters:
    ///   - allowList: Regex patterns that allow content to pass unchanged.
    ///   - denyList: Regex patterns considered forbidden.
    ///   - transformations: Replacements applied when deny patterns are found.
    ///   - logURL: Location where violations are recorded.
    public init(allowList: [String] = [],
                denyList: [String] = [],
                transformations: [String: String] = [:],
                logURL: URL = URL(fileURLWithPath: "logs/payload-violations.log")) {
        self.allowList = allowList
        self.denyList = denyList
        self.transformations = transformations
        self.logURL = logURL
    }

    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        var req = request
        req.body = try inspect(data: request.body, path: request.path, kind: "request")
        return req
    }

    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        var res = response
        res.body = try inspect(data: response.body, path: request.path, kind: "response")
        return res
    }

    private func inspect(data: Data, path: String, kind: String) throws -> Data {
        guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return data }
        var result = text
        let allowRegexes = allowList.compactMap { try? NSRegularExpression(pattern: $0, options: []) }
        for pattern in denyList {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
            if matches.isEmpty { continue }
            var acted = false
            for match in matches.reversed() {
                let substring = (result as NSString).substring(with: match.range)
                if allowRegexes.contains(where: { $0.firstMatch(in: substring, range: NSRange(location: 0, length: substring.utf16.count)) != nil }) {
                    continue
                }
                acted = true
                if let replacement = transformations[pattern] {
                    let ns = result as NSString
                    result = ns.replacingCharacters(in: match.range, with: replacement)
                } else {
                    logViolation(pattern: pattern, path: path, kind: kind, action: "reject")
                    throw PayloadRejectedError()
                }
            }
            if acted && transformations[pattern] != nil {
                logViolation(pattern: pattern, path: path, kind: kind, action: "sanitize")
            }
        }
        return Data(result.utf8)
    }

    private func logViolation(pattern: String, path: String, kind: String, action: String) {
        let line = "\(Date().ISO8601Format()) \(kind) \(path) \(pattern) \(action)\n"
        do {
            let dir = logURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: logURL.path) {
                _ = FileManager.default.createFile(atPath: logURL.path, contents: nil)
            }
            let handle = try FileHandle(forWritingTo: logURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: Data(line.utf8))
        } catch {
            // ignore logging errors
        }
    }
}

public struct PayloadRejectedError: Error {}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

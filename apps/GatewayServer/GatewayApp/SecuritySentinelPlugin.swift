import Foundation
import FountainCodex
import LLMGatewayPlugin

public enum SentinelDecision: String, Decodable {
    case allow
    case deny
    case escalate
}

/// Plugin that consults SecuritySentinel for potentially destructive actions.
public struct SecuritySentinelPlugin: GatewayPlugin {
    private let handlers: Handlers
    private let logURL: URL
    private let patterns: [String]

    /// Creates a new plugin instance.
    /// - Parameters:
    ///   - handlers: LLM gateway handlers used for sentinel consults.
    ///   - logURL: Destination log file.
    ///   - patterns: Path substrings considered destructive.
    public init(handlers: Handlers = Handlers(),
                logURL: URL = URL(fileURLWithPath: "logs/security.log"),
                patterns: [String] = ["delete", "destroy", "truncate"]) {
        self.handlers = handlers
        self.logURL = logURL
        self.patterns = patterns
    }

    /// Consults the sentinel service for a decision.
    /// - Parameters:
    ///   - summary: Text describing the action being evaluated.
    ///   - user: Identifier for the user initiating the action.
    ///   - resources: Resources touched by the action.
    /// - Returns: The sentinel's decision for the action.
    public func consult(summary: String, user: String, resources: [String]) async throws -> SentinelDecision {
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult")
        let body = SecurityCheckRequest(summary: summary, user: user, resources: resources)
        let resp = try await handlers.sentinelConsult(request, body: body)
        let decision = try JSONDecoder().decode(SecurityDecision.self, from: resp.body).decision
        let result = SentinelDecision(rawValue: decision) ?? .escalate
        log(summary: summary, decision: result)
        return result
    }

    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        guard isDestructive(request) else { return request }
        let summary = "\(request.method) \(request.path)"
        let user = request.headers["X-User"] ?? "anonymous"
        let resources = [request.path]
        let decision = try await consult(summary: summary, user: user, resources: resources)
        switch decision {
        case .allow:
            return request
        case .deny:
            throw DeniedError()
        case .escalate:
            throw EscalateError()
        }
    }

    private func isDestructive(_ request: HTTPRequest) -> Bool {
        if request.method.uppercased() == "DELETE" { return true }
        return patterns.contains { request.path.lowercased().contains($0) }
    }

    private func log(summary: String, decision: SentinelDecision) {
        let line = "\(summary) -> \(decision.rawValue)\n"
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

public struct DeniedError: Error {}
public struct EscalateError: Error {}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

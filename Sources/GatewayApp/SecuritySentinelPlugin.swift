import Foundation
import FountainCodex
import LLMGatewayClient

extension APIClient: @unchecked Sendable {}

public enum SentinelDecision: String, Decodable {
    case allow
    case deny
    case escalate
}

private struct SecurityCheckRequest: Codable {
    let summary: String
    let user: String
    let resources: [String]
}

/// Plugin that consults SecuritySentinel for potentially destructive actions.
public struct SecuritySentinelPlugin: GatewayPlugin {
    private let client: APIClient
    private let logURL: URL
    private let patterns: [String]

    /// Creates a new plugin instance.
    /// - Parameters:
    ///   - client: API client used to consult the sentinel service.
    ///   - logURL: Destination log file.
    ///   - patterns: Path substrings considered destructive.
    public init(client: APIClient = APIClient(baseURL: URL(string: "http://localhost:8080")!),
                logURL: URL = URL(fileURLWithPath: "logs/security.log"),
                patterns: [String] = ["delete", "destroy", "truncate"]) {
        self.client = client
        self.logURL = logURL
        self.patterns = patterns
    }

    private struct ConsultRequest: APIRequest {
        typealias Response = ConsultResponse
        typealias Body = SecurityCheckRequest
        let summary: String
        let user: String
        let resources: [String]
        var method: String { "POST" }
        var path: String { "/sentinel/consult" }
        var body: Body? {
            SecurityCheckRequest(summary: summary, user: user, resources: resources)
        }
    }

    private struct ConsultResponse: Decodable {
        let decision: SentinelDecision
    }

    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        guard isDestructive(request) else { return request }
        let summary = "\(request.method) \(request.path)"
        let user = request.headers["X-User"] ?? "anonymous"
        let resources = [request.path]
        let decision = try await client.send(ConsultRequest(summary: summary, user: user, resources: resources)).decision
        log(summary: summary, decision: decision)
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

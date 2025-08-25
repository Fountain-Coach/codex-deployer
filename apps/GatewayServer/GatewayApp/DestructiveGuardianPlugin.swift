import Foundation
import FountainCodex

/// Plugin that blocks destructive requests unless manually approved or authorized via service token.
public struct DestructiveGuardianPlugin: GatewayPlugin {
    private let sensitivePaths: [String]
    private let privilegedTokens: Set<String>
    private let auditURL: URL

    /// Creates a new guardian plugin.
    /// - Parameters:
    ///   - sensitivePaths: Paths requiring additional authorization.
    ///   - privilegedTokens: Service tokens allowing bypass.
    ///   - auditURL: Destination file for the immutable audit trail.
    public init(sensitivePaths: [String] = ["/"],
                privilegedTokens: [String] = [],
                auditURL: URL = URL(fileURLWithPath: "logs/guardian.log")) {
        self.sensitivePaths = sensitivePaths
        self.privilegedTokens = Set(privilegedTokens)
        self.auditURL = auditURL
    }

    /// Inspects incoming requests and enforces manual approval or token authorization.
    /// - Parameter request: The request to evaluate.
    /// - Returns: The original request if authorized.
    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        guard isProtected(request) else { return request }
        let manual = request.headers["X-Manual-Approval"] != nil
        let token = request.headers["X-Service-Token"]
        let tokenValid = token.map { privilegedTokens.contains($0) } ?? false
        let allowed = manual || tokenValid
        log(request: request, allowed: allowed, reason: manual ? "manual" : tokenValid ? "token" : "missing")
        guard allowed else { throw GuardianDeniedError() }
        return request
    }

    private func isProtected(_ request: HTTPRequest) -> Bool {
        let method = request.method.uppercased()
        guard ["DELETE", "PUT", "PATCH"].contains(method) else { return false }
        return sensitivePaths.contains { request.path.hasPrefix($0) }
    }

    private func log(request: HTTPRequest, allowed: Bool, reason: String) {
        let line = "\(request.method) \(request.path) -> \(allowed ? "allow" : "deny") [\(reason)]\n"
        do {
            let dir = auditURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: auditURL.path) {
                _ = FileManager.default.createFile(atPath: auditURL.path, contents: nil)
            }
            let handle = try FileHandle(forWritingTo: auditURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: Data(line.utf8))
        } catch {
            // ignore audit logging errors
        }
    }
}

/// Error thrown when a destructive request lacks authorization.
public struct GuardianDeniedError: Error {}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

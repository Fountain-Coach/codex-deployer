import Foundation
import FountainCodex

/// Simple role-based access control plugin.
/// Enforces a required role for requests matching configured path prefixes.
public struct RoleGuardPlugin: GatewayPlugin, Sendable {
    public let rules: [String: String] // prefix -> requiredRole
    private let validator: TokenValidator

    public init(rules: [String: String], validator: TokenValidator = CredentialStoreValidator()) {
        self.rules = rules
        self.validator = validator
    }

    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        // Find the longest matching prefix rule
        let path = request.path
        let match = rules.keys
            .filter { path == $0 || path.hasPrefix($0.hasSuffix("/") ? $0 : $0 + "/") }
            .sorted { $0.count > $1.count }
            .first
        guard let prefix = match, let required = rules[prefix] else { return request }
        // Extract bearer token
        guard let auth = request.headers["Authorization"], auth.hasPrefix("Bearer ") else {
            throw UnauthorizedError()
        }
        let token = String(auth.dropFirst(7))
        guard let claims = await validator.validate(token: token) else {
            throw UnauthorizedError()
        }
        guard let role = claims.role, role == required else {
            throw ForbiddenError()
        }
        return request
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


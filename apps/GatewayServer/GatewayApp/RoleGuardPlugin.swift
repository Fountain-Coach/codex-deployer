import Foundation
import FountainRuntime

public struct RoleRequirement: Sendable, Codable, Equatable {
    public let roles: [String]?
    public let scopes: [String]?
    public let requireAllScopes: Bool
    public let methods: [String]? // e.g., ["GET","POST"]. If nil, applies to all methods.
    public let deny: Bool // If true, deny regardless of token.
    public init(roles: [String]? = nil,
                scopes: [String]? = nil,
                requireAllScopes: Bool = false,
                methods: [String]? = nil,
                deny: Bool = false) {
        self.roles = roles
        self.scopes = scopes
        self.requireAllScopes = requireAllScopes
        self.methods = methods
        self.deny = deny
    }
}

/// Simple role/scope-based access control plugin.
/// Enforces required roles and/or scopes for requests matching configured path prefixes.
public struct RoleGuardPlugin: GatewayPlugin, Sendable {
    public let rules: [String: RoleRequirement] // prefix -> requirements
    private let validator: TokenValidator

    public init(rules: [String: RoleRequirement], validator: TokenValidator = CredentialStoreValidator()) {
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
        guard let prefix = match, let reqs = rules[prefix] else { return request }
        if let methods = reqs.methods, !methods.isEmpty, !methods.contains(request.method.uppercased()) {
            return request
        }
        if reqs.deny { throw ForbiddenError() }
        // Extract bearer token
        guard let auth = request.headers["Authorization"], auth.hasPrefix("Bearer ") else { throw UnauthorizedError() }
        let token = String(auth.dropFirst(7))
        guard let claims = await validator.validate(token: token) else { throw UnauthorizedError() }
        // Check roles (if any)
        if let roles = reqs.roles, !roles.isEmpty {
            guard let role = claims.role, roles.contains(role) else { throw ForbiddenError() }
        }
        // Check scopes (if any) - require any match
        if let needed = reqs.scopes, !needed.isEmpty {
            let have = Set(claims.scopes)
            if reqs.requireAllScopes {
                // Require all scopes to be present
                if !Set(needed).isSubset(of: have) { throw ForbiddenError() }
            } else {
                // Require any scope match
                if have.intersection(needed).isEmpty { throw ForbiddenError() }
            }
        }
        return request
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

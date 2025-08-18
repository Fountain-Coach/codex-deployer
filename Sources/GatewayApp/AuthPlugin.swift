import Foundation
import FountainCodex

/// Error thrown when authorization fails.
public struct UnauthorizedError: Error {}

/// Error thrown when authorization is denied for insufficient scope or role.
public struct ForbiddenError: Error {}
/// Plugin enforcing bearer token authorization on management endpoints.
public struct AuthPlugin: GatewayPlugin {
    private let validator: TokenValidator
    private let protected: [String: String]

    /// Creates a new auth plugin.
    /// - Parameters:
    ///   - validator: Strategy used to validate access tokens.
    ///   - protected: Map of path prefixes to required roles or scopes.
    public init(validator: TokenValidator = CredentialStoreValidator(),
                protected: [String: String] = ["/metrics": "admin",
                                               "/certificates": "admin",
                                               "/routes": "admin",
                                               "/zones": "admin"]) {
        self.validator = validator
        self.protected = protected
    }

    /// Validates `Authorization: Bearer` tokens for protected paths and enforces role-based access.
    /// - Parameter request: Incoming HTTP request.
    /// - Returns: The request when authorization succeeds.
    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        guard let required = protected.first(where: { request.path.hasPrefix($0.key) })?.value else {
            return request
        }
        guard let auth = request.headers["Authorization"], auth.hasPrefix("Bearer ") else {
            throw UnauthorizedError()
        }
        let token = String(auth.dropFirst(7))
        guard let claims = await validator.validate(token: token) else { throw UnauthorizedError() }
        let scopes = Set(claims.scopes)
        if !(scopes.contains(required) || claims.role == required) {
            throw ForbiddenError()
        }
        var request = request
        request.headers["X-User-Role"] = claims.role ?? required
        return request
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

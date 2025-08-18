import Foundation
import FountainCodex

/// Error thrown when authorization fails.
public struct UnauthorizedError: Error {}

/// Plugin enforcing bearer token authorization on management endpoints.
public struct AuthPlugin: GatewayPlugin {
    private let store: CredentialStore
    private let protected: [String]

    /// Creates a new auth plugin.
    /// - Parameters:
    ///   - store: Credential store used to verify JWTs.
    ///   - protected: Path prefixes requiring authorization.
    public init(store: CredentialStore = CredentialStore(),
                protected: [String] = ["/metrics", "/certificates", "/routes", "/zones", "/chat/"]) {
        self.store = store
        self.protected = protected
    }

    /// Validates `Authorization: Bearer` tokens for protected paths.
    /// - Parameter request: Incoming HTTP request.
    /// - Returns: The request when authorization succeeds.
    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        guard protected.contains(where: { request.path.hasPrefix($0) }) else {
            return request
        }
        guard let auth = request.headers["Authorization"], auth.hasPrefix("Bearer ") else {
            throw UnauthorizedError()
        }
        let token = String(auth.dropFirst(7))
        guard store.verify(jwt: token) else { throw UnauthorizedError() }
        var request = request
        if let role = store.role(for: token) {
            request.headers["X-User-Role"] = role
        }
        return request
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

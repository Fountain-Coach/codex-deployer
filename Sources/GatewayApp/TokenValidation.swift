import Foundation
import FoundationNetworking

/// Claims extracted from a validated access token.
public struct TokenClaims: Sendable {
    /// Optional role claim.
    public let role: String?
    /// Scopes granted to the token.
    public let scopes: [String]
}

/// Protocol for pluggable token validation strategies.
public protocol TokenValidator: Sendable {
    /// Validates the token and returns extracted claims when valid.
    func validate(token: String) async -> TokenClaims?
}

/// Default validator backed by ``CredentialStore``.
public struct CredentialStoreValidator: TokenValidator {
    private let store: CredentialStore
    public init(store: CredentialStore = CredentialStore()) {
        self.store = store
    }
    public func validate(token: String) async -> TokenClaims? {
        guard store.verify(jwt: token) else { return nil }
        let role = store.role(for: token)
        let scopes = role.map { [$0] } ?? []
        return TokenClaims(role: role, scopes: scopes)
    }
}

/// Validator delegating to an OAuth2 introspection endpoint.
public struct OAuth2Validator: TokenValidator {
    private let introspectionURL: URL
    private let clientId: String?
    private let clientSecret: String?
    public init(introspectionURL: URL,
                clientId: String? = nil,
                clientSecret: String? = nil) {
        self.introspectionURL = introspectionURL
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    public init?(environment: [String: String] = ProcessInfo.processInfo.environment) {
        guard let urlStr = environment["GATEWAY_OAUTH2_INTROSPECTION_URL"],
              let url = URL(string: urlStr) else { return nil }
        let id = environment["GATEWAY_OAUTH2_CLIENT_ID"]
        let secret = environment["GATEWAY_OAUTH2_CLIENT_SECRET"]
        self.init(introspectionURL: url, clientId: id, clientSecret: secret)
    }
    public func validate(token: String) async -> TokenClaims? {
        var request = URLRequest(url: introspectionURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "token=\(token)".data(using: .utf8)
        if let id = clientId, let secret = clientSecret {
            let creds = "\(id):\(secret)".data(using: .utf8)!
            let auth = creds.base64EncodedString()
            request.setValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        }
        do {
            let (data, resp) = try await URLSession.shared.data(for: request)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            struct IntrospectionResponse: Decodable {
                let active: Bool
                let scope: String?
                let role: String?
            }
            let result = try JSONDecoder().decode(IntrospectionResponse.self, from: data)
            guard result.active else { return nil }
            let scopes = result.scope?.split(separator: " ").map(String.init) ?? []
            return TokenClaims(role: result.role, scopes: scopes)
        } catch {
            return nil
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

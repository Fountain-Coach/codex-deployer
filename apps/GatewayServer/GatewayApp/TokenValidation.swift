import Foundation
import Crypto
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Error thrown when authorization fails.
public struct UnauthorizedError: Error {}

/// Error thrown when authorization is denied for insufficient scope or role.
public struct ForbiddenError: Error {}

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

/// Provides a symmetric key for HS256 verification.
public protocol KeyProvider: Sendable {
    func symmetricKey() -> SymmetricKey
}

/// Default key provider using `GATEWAY_JWT_SECRET`.
public struct EnvKeyProvider: KeyProvider {
    private let secret: String
    public init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.secret = environment["GATEWAY_JWT_SECRET"] ?? "secret"
    }
    public func symmetricKey() -> SymmetricKey { SymmetricKey(data: Data(secret.utf8)) }
}

/// Validation options for JWT claims.
public struct JWTValidationOptions: Sendable {
    public let issuer: String?
    public let audience: String?
    public let leewaySeconds: Int
    public let requireJTI: Bool
    public init(issuer: String? = ProcessInfo.processInfo.environment["GATEWAY_JWT_ISS"],
                audience: String? = ProcessInfo.processInfo.environment["GATEWAY_JWT_AUD"],
                leewaySeconds: Int = Int(ProcessInfo.processInfo.environment["GATEWAY_JWT_LEEWAY"] ?? "60") ?? 60,
                requireJTI: Bool = (ProcessInfo.processInfo.environment["GATEWAY_JWT_REQUIRE_JTI"] as NSString?)?.boolValue ?? false) {
        self.issuer = issuer
        self.audience = audience
        self.leewaySeconds = leewaySeconds
        self.requireJTI = requireJTI
    }
}

/// Default validator backed by ``CredentialStore``.
public struct CredentialStoreValidator: TokenValidator {
    private let keyProvider: KeyProvider
    private let options: JWTValidationOptions
    public init(keyProvider: KeyProvider = EnvKeyProvider(), options: JWTValidationOptions = JWTValidationOptions()) {
        self.keyProvider = keyProvider
        self.options = options
    }
    public func validate(token: String) async -> TokenClaims? {
        guard let payload = Self.verifyAndDecode(token: token, key: keyProvider.symmetricKey(), options: options) else { return nil }
        let scopes = payload.role.map { [$0] } ?? []
        return TokenClaims(role: payload.role, scopes: scopes)
    }

    private struct JWTPayload: Decodable { let iss: String?; let aud: String?; let sub: String?; let exp: Int; let nbf: Int?; let iat: Int?; let jti: String?; let role: String? }

    private static func verifyAndDecode(token: String, key: SymmetricKey, options: JWTValidationOptions) -> JWTPayload? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        let headerPayload = parts[0] + "." + parts[1]
        guard let sig = Data(base64URLEncoded: String(parts[2])) else { return nil }
        let expected = HMAC<SHA256>.authenticationCode(for: Data(headerPayload.utf8), using: key)
        guard Data(expected) == sig else { return nil }
        guard let payloadData = Data(base64URLEncoded: String(parts[1])),
              let payload = try? JSONDecoder().decode(JWTPayload.self, from: payloadData) else { return nil }
        let now = Int(Date().timeIntervalSince1970)
        // exp with leeway
        guard payload.exp + options.leewaySeconds >= now else { return nil }
        // nbf with leeway
        if let nbf = payload.nbf, nbf - options.leewaySeconds > now { return nil }
        // iss/aud checks if provided
        if let iss = options.issuer, payload.iss != iss { return nil }
        if let aud = options.audience, payload.aud != aud { return nil }
        if options.requireJTI && (payload.jti ?? "").isEmpty { return nil }
        return payload
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

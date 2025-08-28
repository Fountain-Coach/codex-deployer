import Foundation
import FountainCodex
import Crypto

/// Collection of handlers for auth gateway endpoints.
public struct Handlers: Sendable {
    private let secret: String

    public init(secret: String = ProcessInfo.processInfo.environment["GATEWAY_JWT_SECRET"] ?? "secret") {
        self.secret = secret
    }

    private func claims(for token: String) -> ClaimsResponse? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }
        let signingInput = segments[0] + "." + segments[1]
        guard let signatureData = Data(base64URLEncoded: String(segments[2])) else { return nil }
        let key = SymmetricKey(data: Data(secret.utf8))
        let expected = HMAC<SHA256>.authenticationCode(for: Data(signingInput.utf8), using: key)
        guard Data(expected) == signatureData,
              let payloadData = Data(base64URLEncoded: String(segments[1])),
              let payload = try? JSONDecoder().decode(JWTPayload.self, from: payloadData) else { return nil }
        let now = Int(Date().timeIntervalSince1970)
        let leeway = Int(ProcessInfo.processInfo.environment["GATEWAY_JWT_LEEWAY"] ?? "60") ?? 60
        if payload.exp + leeway < now { return nil }
        if let nbf = payload.nbf, nbf - leeway > now { return nil }
        if let iss = ProcessInfo.processInfo.environment["GATEWAY_JWT_ISS"], let pi = payload.iss, iss != pi { return nil }
        if let aud = ProcessInfo.processInfo.environment["GATEWAY_JWT_AUD"], let pa = payload.aud, aud != pa { return nil }
        if ((ProcessInfo.processInfo.environment["GATEWAY_JWT_REQUIRE_JTI"] as NSString?)?.boolValue ?? false) && (payload.jti ?? "").isEmpty { return nil }
        let scopes = payload.role.map { [$0] } ?? []
        return ClaimsResponse(role: payload.role, scopes: scopes)
    }

    private struct JWTPayload: Decodable { let iss: String?; let aud: String?; let nbf: Int?; let exp: Int; let jti: String?; let role: String? }

    /// Validates a provided bearer token.
    public func authValidate(_ request: HTTPRequest, body: ValidateRequest?) async throws -> HTTPResponse {
        guard let token = body?.token, let claims = claims(for: token) else {
            return HTTPResponse(status: 401)
        }
        let resp = ValidationResponse(valid: true, role: claims.role)
        let data = try JSONEncoder().encode(resp)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    /// Returns claims for the bearer token in the Authorization header.
    public func authClaims(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        guard let auth = request.headers["Authorization"], auth.hasPrefix("Bearer "),
              let claims = claims(for: String(auth.dropFirst(7))) else {
            return HTTPResponse(status: 401)
        }
        let data = try JSONEncoder().encode(claims)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }
}

private extension Data {
    init?(base64URLEncoded input: String) {
        var base64 = input
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = 4 - base64.count % 4
        if padding < 4 { base64 += String(repeating: "=", count: padding) }
        guard let data = Data(base64Encoded: base64) else { return nil }
        self = data
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

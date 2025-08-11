// Models for FountainAI Gateway

public struct CertificateInfo: Codable {
    public let issuer: String
    public let notAfter: String
}

public struct CredentialRequest: Codable {
    public let clientId: String
    public let clientSecret: String
}

public struct ErrorResponse: Codable {
    public let error: String
}

public struct RouteInfo: Codable {
    public let id: String
    public let methods: [String]
    public let path: String
    public let proxyEnabled: Bool
    public let rateLimit: Int
    public let target: String
}

public struct TokenResponse: Codable {
    public let expiresAt: String
    public let token: String
}

public typealias gatewayHealthResponse = [String: String]

public typealias gatewayMetricsResponse = [String: Int]

public typealias listRoutesResponse = [RouteInfo]


© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation
import FountainCodex

/// Plugin providing auth validation and claims endpoints.
public struct AuthGatewayPlugin: Sendable {
    public let router: Router

    public init(secret: String = ProcessInfo.processInfo.environment["GATEWAY_JWT_SECRET"] ?? "secret") {
        self.router = Router(handlers: Handlers(secret: secret))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

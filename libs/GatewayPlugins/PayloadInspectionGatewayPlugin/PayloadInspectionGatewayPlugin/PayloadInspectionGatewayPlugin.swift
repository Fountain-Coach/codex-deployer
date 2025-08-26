import Foundation
import FountainCodex

/// Plugin providing payload inspection capabilities for the gateway.
public struct PayloadInspectionGatewayPlugin: Sendable {
    public let router: Router
    private let handlers: Handlers

    public init() {
        let h = Handlers()
        self.handlers = h
        self.router = Router(handlers: h)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

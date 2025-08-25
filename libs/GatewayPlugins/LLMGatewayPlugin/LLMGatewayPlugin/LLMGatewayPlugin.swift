import Foundation
import FountainCodex

/// Plugin exposing sentinel consult and CoT endpoints.
public struct LLMGatewayPlugin: Sendable {
    public let router: Router

    /// Creates a new plugin instance.
    /// - Parameter cotLogURL: Optional location of the CoT log file.
    public init(cotLogURL: URL? = nil) {
        self.router = Router(handlers: Handlers(cotLogURL: cotLogURL))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

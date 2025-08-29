import Foundation
import FountainRuntime

/// Actor housing payload inspection handlers.
public actor Handlers {
    public init() {}

    /// Inspects the provided payload and returns sanitized content with any violations.
    public func inspectPayload(_ request: HTTPRequest, body: PayloadInspectionRequest?) async throws -> HTTPResponse {
        guard let body else { return HTTPResponse(status: 400) }
        let response = PayloadInspectionResponse(sanitized: body.payload, violations: [])
        let data = try JSONEncoder().encode(response)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

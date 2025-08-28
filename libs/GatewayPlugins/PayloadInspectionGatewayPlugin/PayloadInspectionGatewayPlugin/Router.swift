import Foundation
import FountainRuntime

/// Routes payload inspection requests.
public struct Router: Sendable {
    public var handlers: Handlers
    public init(handlers: Handlers = Handlers()) { self.handlers = handlers }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse? {
        switch (request.method, request.path) {
        case ("POST", "/inspect"):
            let body = try? JSONDecoder().decode(PayloadInspectionRequest.self, from: request.body)
            return try await handlers.inspect(request, body: body)
        default:
            return nil
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation
import ServiceShared

public struct Router {
    public var handlers: Handlers

    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        switch (request.method, request.path) {
        case ("POST", let path) where path == "/tools/register" || path.hasPrefix("/tools/register?"):
            return try await handlers.registerOpenapi(request)
        case ("GET", let path) where path == "/tools" || path.hasPrefix("/tools?"):
            return try await handlers.listTools(request)
        case ("GET", "/metrics"):
            let text = await PrometheusAdapter.shared.exposition()
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data(text.utf8))
        default:
            return HTTPResponse(status: 404)
        }
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

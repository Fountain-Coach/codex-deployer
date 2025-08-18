import Foundation

public struct Router {
    public var handlers: Handlers

    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        switch (request.method, request.path) {
        case ("GET", "/metrics"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.metricsMetricsGet(request, body: body)
        case ("POST", "/sentinel/consult"):
            let body = try? JSONDecoder().decode(SecurityCheckRequest.self, from: request.body)
            return try await handlers.sentinelconsult(request, body: body)
        case ("POST", "/chat"):
            let body = try? JSONDecoder().decode(ChatRequest.self, from: request.body)
            return try await handlers.chatwithobjective(request, body: body)
        case ("GET", let path) where path.hasPrefix("/chat/") && path.hasSuffix("/cot"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.chatcot(request, body: body)
        default:
            return HTTPResponse(status: 404)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

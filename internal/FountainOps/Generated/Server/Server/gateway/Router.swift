import Foundation

public struct Router {
    public var handlers: Handlers

    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        switch (request.method, request.path) {
        case ("GET", "/certificates"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.certificateinfo(request, body: body)
        case ("GET", "/health"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.gatewayhealth(request, body: body)
        case ("GET", "/metrics"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.gatewaymetrics(request, body: body)
        case ("GET", "/routes"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.listroutes(request, body: body)
        case ("POST", "/routes"):
            let body = try? JSONDecoder().decode(RouteInfo.self, from: request.body)
            return try await handlers.createroute(request, body: body)
        case ("PUT", "/routes/{routeId}"):
            let body = try? JSONDecoder().decode(RouteInfo.self, from: request.body)
            return try await handlers.updateroute(request, body: body)
        case ("DELETE", "/routes/{routeId}"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.deleteroute(request, body: body)
        case ("POST", "/certificates/renew"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.renewcertificate(request, body: body)
        case ("POST", "/auth/token"):
            let body = try? JSONDecoder().decode(CredentialRequest.self, from: request.body)
            return try await handlers.issueauthtoken(request, body: body)
        default:
            return HTTPResponse(status: 404)
        }
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

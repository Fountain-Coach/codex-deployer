import Foundation

public struct Router {
    public var handlers: Handlers

    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        switch (request.method, request.path) {
        case ("GET", "/v1/pages"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.querypages(request, body: body)
        case ("POST", "/v1/browse"):
            let body = try? JSONDecoder().decode(BrowseRequest.self, from: request.body)
            return try await handlers.browseanddissect(request, body: body)
        case ("POST", "/v1/snapshot"):
            let body = try? JSONDecoder().decode(SnapshotRequest.self, from: request.body)
            return try await handlers.snapshotonly(request, body: body)
        case ("GET", "/v1/health"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.health(request, body: body)
        case ("GET", "/v1/entities"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.queryentities(request, body: body)
        case ("POST", "/v1/index"):
            let body = try? JSONDecoder().decode(IndexRequest.self, from: request.body)
            return try await handlers.indexanalysis(request, body: body)
        case ("GET", "/v1/export"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.exportartifacts(request, body: body)
        case ("GET", "/v1/segments"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.querysegments(request, body: body)
        case ("GET", "/v1/pages/{id}"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.getpage(request, body: body)
        case ("POST", "/v1/analyze"):
            let body = try? JSONDecoder().decode(AnalyzeRequest.self, from: request.body)
            return try await handlers.analyzesnapshot(request, body: body)
        default:
            return HTTPResponse(status: 404)
        }
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

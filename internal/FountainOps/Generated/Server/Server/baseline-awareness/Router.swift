/// Routes HTTP requests to service handlers.
/// Documentation lives in `docs/handbook/code_reference.md`.
import Foundation
import ServiceShared

public struct Router {
    public var handlers: Handlers

    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        let path = request.path.split(separator: "?").first.map(String.init) ?? request.path
        switch (request.method, path) {
        case ("GET", "/corpus/semantic-arc"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.readsemanticarc(request, body: body)
        case ("GET", "/corpus/summary/{corpus_id}"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.summarizehistory(request, body: body)
        case ("POST", "/corpus/reflections"):
            let body = try? JSONDecoder().decode(ReflectionRequest.self, from: request.body)
            return try await handlers.addreflection(request, body: body)
        case ("GET", "/corpus/history/{corpus_id}"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.listhistory(request, body: body)
        case ("POST", "/corpus/drift"):
            let body = try? JSONDecoder().decode(DriftRequest.self, from: request.body)
            return try await handlers.adddrift(request, body: body)
        case ("GET", "/corpus/history"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.listhistoryanalytics(request, body: body)
        case ("POST", "/corpus/patterns"):
            let body = try? JSONDecoder().decode(PatternsRequest.self, from: request.body)
            return try await handlers.addpatterns(request, body: body)
        case ("GET", "/health"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.healthHealthGet(request, body: body)
        case ("GET", "/metrics"):
            let text = await PrometheusAdapter.shared.exposition()
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data(text.utf8))
        case ("GET", "/corpus/history/stream"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.streamhistoryanalytics(request, body: body)
        case ("GET", "/corpus/reflections/{corpus_id}"):
            let body = try? JSONDecoder().decode(NoBody.self, from: request.body)
            return try await handlers.listreflections(request, body: body)
        case ("POST", "/corpus/init"):
            let body = try? JSONDecoder().decode(InitIn.self, from: request.body)
            return try await handlers.initializecorpus(request, body: body)
        case ("POST", "/corpus/baseline"):
            let body = try? JSONDecoder().decode(BaselineRequest.self, from: request.body)
            return try await handlers.addbaseline(request, body: body)
        default:
            return HTTPResponse(status: 404)
        }
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

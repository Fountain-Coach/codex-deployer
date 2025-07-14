import Foundation
import BaselineAwarenessService

/// Service handlers that persist data via `BaselineStore`.
public struct Handlers {
    let store: BaselineStore

    public init(store: BaselineStore = .shared) {
        self.store = store
    }

    /// Enqueue the default reflection for the corpus.
    public func bootstrapenqueuereflection(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let model = try? JSONDecoder().decode(InitIn.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        let reflection = ReflectionRequest(content: "role-health-check", corpusId: model.corpusId, question: "health", reflectionId: "role-health-check")
        await store.addReflection(reflection)
        let resp = InitOut(message: "queued")
        let data = try JSONEncoder().encode(resp)
        return HTTPResponse(body: data)
    }

    /// Initialize a new corpus and seed default roles.
    public func bootstrapinitializecorpus(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let initReq = try? JSONDecoder().decode(InitIn.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        _ = await store.createCorpus(id: initReq.corpusId)
        _ = try await bootstrapseedroles(request)
        let reflection = ReflectionRequest(content: "role-health-check", corpusId: initReq.corpusId, question: "health", reflectionId: "role-health-check")
        await store.addReflection(reflection)
        let out = InitOut(message: "created")
        let data = try JSONEncoder().encode(out)
        return HTTPResponse(body: data)
    }

    public func bootstrappromotereflection(_ request: HTTPRequest) async throws -> HTTPResponse {
        return HTTPResponse()
    }

    /// Seed default GPT role prompts.
    public func bootstrapseedroles(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let _ = try? JSONDecoder().decode(RoleInitRequest.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        let data = try JSONEncoder().encode(defaultRoles())
        return HTTPResponse(body: data)
    }

    /// Seed default GPT role prompts.
    public func seedroles(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let _ = try? JSONDecoder().decode(RoleInitRequest.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        let data = try JSONEncoder().encode(defaultRoles())
        return HTTPResponse(body: data)
    }

    /// Store a new baseline snapshot via the Awareness API.
    public func bootstrapaddbaseline(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let baseline = try? JSONDecoder().decode(BaselineIn.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        let req = BaselineRequest(baselineId: baseline.baselineId, content: baseline.content, corpusId: baseline.corpusId)
        await store.addBaseline(req)
        return HTTPResponse(status: 200)
    }

    private func defaultRoles() -> RoleDefaults {
        RoleDefaults(
            drift: "Analyze drift",
            history: "Summarize history",
            patterns: "Detect patterns",
            semantic_arc: "Synthesize semantic arc",
            view_creator: "Create view"
        )
    }
}

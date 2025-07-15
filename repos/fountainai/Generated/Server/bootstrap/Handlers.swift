import Foundation
import BaselineAwarenessService
import ServiceShared

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
        let comps = URLComponents(string: request.path)
        let corpusId = comps?.queryItems?.first(where: { $0.name == "corpusId" })?.value
        let roleName = comps?.queryItems?.first(where: { $0.name == "roleName" })?.value
        guard let cid = corpusId, let name = roleName else {
            return HTTPResponse(status: 400)
        }
        guard let reflection = await store.latestReflection(for: cid) else {
            return HTTPResponse(status: 404)
        }
        let info = RoleInfo(name: name, prompt: reflection.content)
        let role = Role(name: name, prompt: reflection.content, corpusId: cid)
        await store.addRole(role)
        let data = try JSONEncoder().encode(info)
        return HTTPResponse(body: data)
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
        let drift = DriftRequest(content: "drift for \(baseline.baselineId)", corpusId: baseline.corpusId, driftId: "\(baseline.baselineId)-drift")
        await store.addDrift(drift)
        let patterns = PatternsRequest(content: "patterns for \(baseline.baselineId)", corpusId: baseline.corpusId, patternsId: "\(baseline.baselineId)-patterns")
        await store.addPatterns(patterns)
        let bodyText = "event: drift\ndata: \(drift.content)\n\nevent: patterns\ndata: \(patterns.content)\n\n"
        let data = Data(bodyText.utf8)
        return HTTPResponse(status: 200, headers: ["Content-Type": "text/event-stream"], body: data)
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

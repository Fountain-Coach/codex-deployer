import Foundation
import TypesensePersistence
import FountainCodex

public struct InitIn: Codable { public let corpusId: String }
public struct InitOut: Codable { public let message: String }
public struct BaselineIn: Codable { public let corpusId: String; public let baselineId: String; public let content: String }
public struct RoleInitRequest: Codable { public let corpusId: String }
public struct RoleDefaults: Codable { public let drift: String; public let semantic_arc: String; public let patterns: String; public let history: String; public let view_creator: String }

public struct HTTPRequest { public let method: String; public let path: String; public let body: Data; public init(method: String, path: String, body: Data = Data()) { self.method = method; self.path = path; self.body = body } }
public struct HTTPResponse { public let status: Int; public let headers: [String:String]; public let body: Data; public init(status: Int, headers: [String:String] = [:], body: Data = Data()) { self.status = status; self.headers = headers; self.body = body } }

public final class BootstrapRouter: @unchecked Sendable {
    let persistence: TypesensePersistenceService
    public init(persistence: TypesensePersistenceService) { self.persistence = persistence }

    private func defaultRoles() -> RoleDefaults {
        RoleDefaults(
            drift: "You are Drift, FountainAI’s baseline-drift detective. Compare a new baseline snapshot against prior versions to detect narrative or thematic drift and report the most significant changes.",
            semantic_arc: "You are Semantic Arc, tasked with tracing the corpus’s overarching narrative arc. Review the corpus history and synthesize a high-level storyline that highlights major turning points and transitions.",
            patterns: "You are Patterns, a spotter of recurring motifs, themes, or rhetorical structures. Inspect the corpus and list the strongest patterns you find.",
            history: "You are History, the curator of past reflections and events. Maintain a chronological log showing how the corpus has grown and changed, focusing on context useful for future analysis.",
            view_creator: "You are View Creator, responsible for assembling human-friendly views of the corpus and analyses. Produce a simple markdown or tabular view to help a human browse the information."
        )
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        let pathOnly = request.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? request.path
        switch (request.method, pathOnly) {
        case ("GET", "/metrics"):
            let uptime = Int(ProcessInfo.processInfo.systemUptime)
            let body = Data("bootstrap_uptime_seconds \(uptime)\n".utf8)
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)
        case ("POST", "/bootstrap/corpus/init"):
            guard let input = try? JSONDecoder().decode(InitIn.self, from: request.body) else {
                return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
            }
            let req = TypesensePersistence.CorpusCreateRequest(corpusId: input.corpusId)
            let resp = try await persistence.createCorpus(req)
            let roles = defaultRoles()
            let roleDocs: [Role] = [
                .init(corpusId: input.corpusId, name: "drift", prompt: roles.drift),
                .init(corpusId: input.corpusId, name: "semantic_arc", prompt: roles.semantic_arc),
                .init(corpusId: input.corpusId, name: "patterns", prompt: roles.patterns),
                .init(corpusId: input.corpusId, name: "history", prompt: roles.history),
                .init(corpusId: input.corpusId, name: "view_creator", prompt: roles.view_creator)
            ]
            _ = try await persistence.seedDefaultRoles(corpusId: input.corpusId, defaults: roleDocs)
            let out = InitOut(message: "corpus \(resp.corpusId) initialized and roles seeded")
            let data = try JSONEncoder().encode(out)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("POST", "/bootstrap/roles/seed"), ("POST", "/bootstrap/roles"):
            guard let input = try? JSONDecoder().decode(RoleInitRequest.self, from: request.body) else {
                return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
            }
            let roles = defaultRoles()
            let roleDocs: [Role] = [
                .init(corpusId: input.corpusId, name: "drift", prompt: roles.drift),
                .init(corpusId: input.corpusId, name: "semantic_arc", prompt: roles.semantic_arc),
                .init(corpusId: input.corpusId, name: "patterns", prompt: roles.patterns),
                .init(corpusId: input.corpusId, name: "history", prompt: roles.history),
                .init(corpusId: input.corpusId, name: "view_creator", prompt: roles.view_creator)
            ]
            _ = try await persistence.seedDefaultRoles(corpusId: input.corpusId, defaults: roleDocs)
            let data = try JSONEncoder().encode(roles)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("POST", "/bootstrap/baseline"):
            guard let input = try? JSONDecoder().decode(BaselineIn.self, from: request.body) else {
                return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
            }
            _ = try await persistence.addBaseline(.init(corpusId: input.corpusId, baselineId: input.baselineId, content: input.content))
            Task.detached { [persistence] in
                _ = try? await persistence.addDrift(.init(corpusId: input.corpusId, driftId: "\(input.baselineId)-drift", content: "auto-generated drift"))
                _ = try? await persistence.addPatterns(.init(corpusId: input.corpusId, patternsId: "\(input.baselineId)-patterns", content: "auto-generated patterns"))
            }
            // Basic SSE emulation: if path contains sse=1, return an SSE event stream payload
            if request.path.contains("sse=1") {
                let sse = """
                event: drift
                data: {"status":"started"}

                event: patterns
                data: {"status":"started"}

                event: complete
                data: {}
                
                """
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/event-stream", "Cache-Control": "no-cache"], body: Data(sse.utf8))
            } else {
                let data = try JSONSerialization.data(withJSONObject: [:])
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
        default:
            return HTTPResponse(status: 404)
        }
    }
}

public func makeBootstrapKernel(service svc: TypesensePersistenceService) -> HTTPKernel {
    let router = BootstrapRouter(persistence: svc)
    return HTTPKernel { req in
        let br = HTTPRequest(method: req.method, path: req.path, body: req.body)
        let resp = try await router.route(br)
        return FountainCodex.HTTPResponse(status: resp.status, headers: resp.headers, body: resp.body)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

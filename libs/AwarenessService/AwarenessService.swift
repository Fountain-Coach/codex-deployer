import Foundation
import TypesensePersistence
import FountainCodex

public struct InitIn: Codable { public let corpusId: String }
public struct InitOut: Codable { public let message: String }
public struct BaselineRequest: Codable { public let corpusId: String; public let baselineId: String; public let content: String }
public struct DriftRequest: Codable { public let corpusId: String; public let driftId: String; public let content: String }
public struct PatternsRequest: Codable { public let corpusId: String; public let patternsId: String; public let content: String }
public struct ReflectionRequest: Codable { public let corpusId: String; public let reflectionId: String; public let question: String; public let content: String }
public struct ReflectionSummaryResponse: Codable { public let message: String }
public struct HistorySummaryResponse: Codable { public let summary: String }

public struct HTTPRequest { public let method: String; public let path: String; public let body: Data; public init(method: String, path: String, body: Data = Data()) { self.method = method; self.path = path; self.body = body } }
public struct HTTPResponse { public let status: Int; public let headers: [String:String]; public let body: Data; public init(status: Int, headers: [String:String] = [:], body: Data = Data()) { self.status = status; self.headers = headers; self.body = body } }

public final class AwarenessRouter: @unchecked Sendable {
    let persistence: TypesensePersistenceService
    public init(persistence: TypesensePersistenceService) { self.persistence = persistence }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        let pathOnly = request.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? request.path
        switch (request.method, pathOnly) {
        case ("GET", "/health"):
            let data = try JSONSerialization.data(withJSONObject: ["status": "ok"]) 
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("GET", "/metrics"):
            let uptime = Int(ProcessInfo.processInfo.systemUptime)
            let body = Data("awareness_uptime_seconds \(uptime)\n".utf8)
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)
        case ("POST", "/corpus/init"):
            if let input = try? JSONDecoder().decode(InitIn.self, from: request.body) {
                let req = TypesensePersistence.CorpusCreateRequest(corpusId: input.corpusId)
                let resp = try await persistence.createCorpus(req)
                let out = InitOut(message: "corpus \(resp.corpusId) created")
                let data = try JSONEncoder().encode(out)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/baseline"):
            if let input = try? JSONDecoder().decode(BaselineRequest.self, from: request.body) {
                _ = try await persistence.addBaseline(.init(corpusId: input.corpusId, baselineId: input.baselineId, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/drift"):
            if let input = try? JSONDecoder().decode(DriftRequest.self, from: request.body) {
                _ = try await persistence.addDrift(.init(corpusId: input.corpusId, driftId: input.driftId, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/patterns"):
            if let input = try? JSONDecoder().decode(PatternsRequest.self, from: request.body) {
                _ = try await persistence.addPatterns(.init(corpusId: input.corpusId, patternsId: input.patternsId, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/reflections"):
            if let input = try? JSONDecoder().decode(ReflectionRequest.self, from: request.body) {
                _ = try await persistence.addReflection(.init(corpusId: input.corpusId, reflectionId: input.reflectionId, question: input.question, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        default:
            break
        }
        // Parameterized routes
        let segments = pathOnly.split(separator: "/").map(String.init)
        if request.method == "GET" && segments.count == 3 && segments[0] == "corpus" && segments[1] == "reflections" {
            let corpusId = segments[2]
            let (total, _) = try await persistence.listReflections(corpusId: corpusId)
            let data = try JSONEncoder().encode(ReflectionSummaryResponse(message: "\(total) reflections"))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && segments.count == 3 && segments[0] == "corpus" && segments[1] == "history" {
            let corpusId = segments[2]
            let (bCount, _) = try await persistence.listBaselines(corpusId: corpusId)
            let (rCount, _) = try await persistence.listReflections(corpusId: corpusId)
            let summary = "baselines=\(bCount), reflections=\(rCount)"
            let data = try JSONEncoder().encode(HistorySummaryResponse(summary: summary))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && segments.count == 3 && segments[0] == "corpus" && segments[1] == "summary" {
            let corpusId = segments[2]
            let (bCount, _) = try await persistence.listBaselines(corpusId: corpusId)
            let (rCount, _) = try await persistence.listReflections(corpusId: corpusId)
            let summary = "summary for \(corpusId): baselines=\(bCount), reflections=\(rCount)"
            let data = try JSONEncoder().encode(HistorySummaryResponse(summary: summary))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && pathOnly == "/corpus/history" {
            let data = try JSONSerialization.data(withJSONObject: ["events": []])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && pathOnly == "/corpus/semantic-arc" {
            let data = try JSONSerialization.data(withJSONObject: ["arc": []])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && pathOnly == "/corpus/history/stream" {
            let data = try JSONSerialization.data(withJSONObject: [:])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        return HTTPResponse(status: 404)
    }
}

public func makeAwarenessKernel(service svc: TypesensePersistenceService) -> HTTPKernel {
    let router = AwarenessRouter(persistence: svc)
    return HTTPKernel { req in
        let ar = HTTPRequest(method: req.method, path: req.path, body: req.body)
        let resp = try await router.route(ar)
        return FountainCodex.HTTPResponse(status: resp.status, headers: resp.headers, body: resp.body)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

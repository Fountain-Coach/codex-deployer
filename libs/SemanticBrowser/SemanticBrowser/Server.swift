import Foundation
import FountainCodex

public func makeSemanticKernel(service: SemanticMemoryService) -> HTTPKernel {
    func qp(_ path: String) -> [String: String] {
        guard let i = path.firstIndex(of: "?") else { return [:] }
        let q = path[path.index(after: i)...]
        var out: [String: String] = [:]
        for pair in q.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            if parts.count == 2 { out[parts[0]] = parts[1] }
        }
        return out
    }
    return HTTPKernel { req in
        let pathOnly = req.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? req.path
        let segs = pathOnly.split(separator: "/", omittingEmptySubsequences: true)
        switch (req.method, segs) {
        case ("GET", ["v1", "health"]):
            let body = try? JSONSerialization.data(withJSONObject: ["status": "ok", "version": "0.2.0", "browserPool": ["capacity": 0, "inUse": 0]])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: body ?? Data())
        case ("GET", ["v1", "pages"]):
            let params = qp(req.path)
            let limit = min(max(Int(params["limit"] ?? "20") ?? 20, 1), 200)
            let offset = max(Int(params["offset"] ?? "0") ?? 0, 0)
            let (total, items) = await service.queryPages(q: params["q"], host: params["host"], lang: params["lang"], limit: limit, offset: offset)
            let obj: [String: Any] = ["total": total, "items": try items.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }]
            let data = try JSONSerialization.data(withJSONObject: obj)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("GET", ["v1", "segments"]):
            let params = qp(req.path)
            let limit = min(max(Int(params["limit"] ?? "20") ?? 20, 1), 200)
            let offset = max(Int(params["offset"] ?? "0") ?? 0, 0)
            let (total, items) = await service.querySegments(q: params["q"], kind: params["kind"], entity: params["entity"], limit: limit, offset: offset)
            let obj: [String: Any] = ["total": total, "items": try items.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }]
            let data = try JSONSerialization.data(withJSONObject: obj)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("GET", ["v1", "entities"]):
            let params = qp(req.path)
            let limit = min(max(Int(params["limit"] ?? "20") ?? 20, 1), 200)
            let offset = max(Int(params["offset"] ?? "0") ?? 0, 0)
            let (total, items) = await service.queryEntities(q: params["q"], type: params["type"], limit: limit, offset: offset)
            let obj: [String: Any] = ["total": total, "items": try items.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }]
            let data = try JSONSerialization.data(withJSONObject: obj)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("POST", ["v1", "index"]):
            do {
                let reqObj = try JSONDecoder().decode(SemanticMemoryService.IndexRequest.self, from: req.body)
                let result = await service.ingest(reqObj)
                let data = try JSONEncoder().encode(result)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            } catch {
                return HTTPResponse(status: 400)
            }
        default:
            return HTTPResponse(status: 404)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

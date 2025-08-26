import Foundation
import FountainCodex

actor SimpleRateLimiter {
    private var buckets: [String: (start: TimeInterval, count: Int)] = [:]
    func allow(id: String, limitPerMinute: Int) -> Bool {
        let now = Date().timeIntervalSince1970
        var entry = buckets[id] ?? (start: now, count: 0)
        if now - entry.start >= 60 {
            entry = (start: now, count: 0)
        }
        if entry.count + 1 > limitPerMinute { buckets[id] = entry; return false }
        entry.count += 1
        buckets[id] = entry
        return true
    }
}

public func makeSemanticKernel(service: SemanticMemoryService, engine: BrowserEngine? = nil, apiKey: String? = nil, limiter: SimpleRateLimiter? = nil, limitPerMinute: Int = 60) -> HTTPKernel {
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
        if let apiKey, !apiKey.isEmpty {
            if (req.headers["X-API-Key"] ?? "") != apiKey { return HTTPResponse(status: 401) }
        }
        if let limiter {
            let client = req.headers["X-Forwarded-For"] ?? req.headers["X-Client-Id"] ?? "anonymous"
            let ok = await limiter.allow(id: client, limitPerMinute: limitPerMinute)
            if !ok { return HTTPResponse(status: 429, headers: ["Content-Type": "text/plain"], body: Data("too many requests".utf8)) }
        }
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
            if let reqObj = try? JSONDecoder().decode(SemanticMemoryService.IndexRequest.self, from: req.body) {
                let result = await service.ingest(reqObj)
                if let data = try? JSONEncoder().encode(result) { return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data) }
                return HTTPResponse(status: 200)
            } else if let full = try? JSONDecoder().decode(SemanticMemoryService.FullAnalysis.self, from: req.body) {
                let result = await service.ingest(full: full)
                if let data = try? JSONEncoder().encode(result) { return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data) }
                return HTTPResponse(status: 200)
            } else {
                return HTTPResponse(status: 400)
            }
        case ("POST", ["v1", "snapshot"]):
            struct SnapshotRequest: Codable { let url: String; let storeArtifacts: Bool? }
            if let sreq = try? JSONDecoder().decode(SnapshotRequest.self, from: req.body) {
                let id = UUID().uuidString
                let (html, text): (String, String)
                if let engine {
                    if let result = try? await engine.snapshotHTML(for: sreq.url) { html = result.html; text = result.text } else { html = ""; text = sreq.url }
                } else {
                    html = "<html><body><h1>\(sreq.url)</h1></body></html>"; text = sreq.url
                }
                let snap = SemanticMemoryService.Snapshot(id: id, url: sreq.url, renderedHTML: html, renderedText: text)
                if sreq.storeArtifacts ?? true { await service.store(snapshot: snap) }
                if let data = try? JSONEncoder().encode(["snapshot": ["id": id, "url": sreq.url, "rendered": ["html": html, "text": text]]]) {
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
                }
                return HTTPResponse(status: 200)
            }
            return HTTPResponse(status: 400)
        case ("POST", ["v1", "analyze"]):
            struct AnalyzeRequest: Codable { let snapshot: SemanticMemoryService.Snapshot?; let snapshotRef: SnapshotRef?; struct SnapshotRef: Codable { let snapshotId: String } }
            if let areq = try? JSONDecoder().decode(AnalyzeRequest.self, from: req.body) {
                let snap = areq.snapshot ?? (areq.snapshotRef.flatMap { await service.loadSnapshot(id: $0.snapshotId) })
                guard let snap else { return HTTPResponse(status: 400) }
                let fid = UUID().uuidString
                let full = SemanticMemoryService.FullAnalysis(
                    envelope: .init(id: fid, source: .init(uri: snap.url), contentType: "text/html", language: "en"),
                    blocks: [ .init(id: fid+"-h", kind: "heading", text: snap.renderedText) ],
                    semantics: .init(entities: [])
                )
                await service.store(analysis: full)
                if let data = try? JSONEncoder().encode(full) {
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
                }
                return HTTPResponse(status: 200)
            }
            return HTTPResponse(status: 400)
        case ("POST", ["v1", "browse"]):
            struct BrowseRequest: Codable { let url: String; let index: IndexOpt?; struct IndexOpt: Codable { let enabled: Bool? } }
            if let breq = try? JSONDecoder().decode(BrowseRequest.self, from: req.body) {
                let sid = UUID().uuidString
                let (html, text): (String, String)
                if let engine {
                    if let result = try? await engine.snapshotHTML(for: breq.url) { html = result.html; text = result.text } else { html = ""; text = breq.url }
                } else {
                    html = "<html><body><h1>\(breq.url)</h1></body></html>"; text = breq.url
                }
                let snap = SemanticMemoryService.Snapshot(id: sid, url: breq.url, renderedHTML: html, renderedText: text)
                await service.store(snapshot: snap)
                let fid = UUID().uuidString
                let full = SemanticMemoryService.FullAnalysis(
                    envelope: .init(id: fid, source: .init(uri: breq.url), contentType: "text/html", language: "en"),
                    blocks: [ .init(id: fid+"-h", kind: "heading", text: text) ],
                    semantics: .init(entities: [])
                )
                await service.store(analysis: full)
                var indexObj: Any = NSNull()
                if breq.index?.enabled ?? true {
                    let res = await service.ingest(full: full)
                    indexObj = try JSONSerialization.jsonObject(with: JSONEncoder().encode(res))
                }
                let resp: [String: Any] = [
                    "snapshot": ["id": sid, "url": breq.url, "rendered": ["html": html, "text": text]],
                    "analysis": try JSONSerialization.jsonObject(with: JSONEncoder().encode(full)),
                    "index": indexObj
                ]
                if let data = try? JSONSerialization.data(withJSONObject: resp) {
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
                }
                return HTTPResponse(status: 200)
            }
            return HTTPResponse(status: 400)
        case ("GET", let seg) where seg.count == 3 && seg[0] == "v1" && seg[1] == "pages":
            let id = String(seg[2])
            if let p = await service.getPage(id: id), let data = try? JSONEncoder().encode(p) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 404)
        case ("GET", ["v1", "export"]):
            func _qp(_ path: String) -> [String: String] {
                guard let i = path.firstIndex(of: "?") else { return [:] }
                let q = path[path.index(after: i)...]
                var out: [String: String] = [:]
                for pair in q.split(separator: "&") { let parts = pair.split(separator: "=", maxSplits: 1).map(String.init); if parts.count == 2 { out[parts[0]] = parts[1] } }
                return out
            }
            let eparams = _qp(req.path)
            guard let pageId = eparams["pageId"], let format = eparams["format"] else { return HTTPResponse(status: 400) }
            if format == "snapshot.html", let snap = await service.loadSnapshot(id: pageId) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/html"], body: Data(snap.renderedHTML.utf8))
            }
            if format == "snapshot.text", let snap = await service.loadSnapshot(id: pageId) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data(snap.renderedText.utf8))
            }
            if format == "analysis.json", let a = await service.loadAnalysis(id: pageId), let data = try? JSONEncoder().encode(a) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            if format == "tables.csv", let a = await service.loadAnalysis(id: pageId) {
                if let table = a.blocks.compactMap({ $0.table }).first {
                    var csv = ""
                    if let cols = table.columns, !cols.isEmpty { csv += cols.joined(separator: ",") + "
" }
                    for row in table.rows { csv += row.joined(separator: ",") + "
" }
                    return HTTPResponse(status: 200, headers: ["Content-Type": "text/csv"], body: Data(csv.utf8))
                }
                return HTTPResponse(status: 404)
            }
            return HTTPResponse(status: 404)
        default:
            return HTTPResponse(status: 404)
        }
    }
}

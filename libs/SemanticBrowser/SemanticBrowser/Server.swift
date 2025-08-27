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
            guard parts.count == 2 else { continue }
            let key = parts[0].replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? parts[0]
            let val = parts[1].replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? parts[1]
            out[key] = val
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
            if let apiReq = try? JSONDecoder().decode(APIModels.IndexRequest.self, from: req.body) {
                // Map API Analysis to internal FullAnalysis
                let a = apiReq.analysis
                let blocks: [SemanticMemoryService.FullAnalysis.Block] = a.blocks.map { .init(id: $0.id, kind: $0.kind, text: $0.text, table: $0.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }) }
                let ents: [SemanticMemoryService.FullAnalysis.Semantics.Entity] = (a.semantics?.entities ?? []).map { .init(id: $0.id, name: $0.name, type: $0.type) }
                let full = SemanticMemoryService.FullAnalysis(
                    envelope: .init(id: a.envelope.id, source: .init(uri: a.envelope.source?.uri), contentType: a.envelope.contentType, language: a.envelope.language),
                    blocks: blocks,
                    semantics: .init(entities: ents)
                )
                let result = await service.ingest(full: full)
                if let data = try? JSONEncoder().encode(APIModels.IndexResult(pagesUpserted: result.pagesUpserted, segmentsUpserted: result.segmentsUpserted, entitiesUpserted: result.entitiesUpserted, tablesUpserted: result.tablesUpserted)) {
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
                }
                return HTTPResponse(status: 200)
            } else if let reqObj = try? JSONDecoder().decode(SemanticMemoryService.IndexRequest.self, from: req.body) {
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
            if let sreq = try? JSONDecoder().decode(APIModels.SnapshotRequest.self, from: req.body) {
                let sid = UUID().uuidString
                let (html, text): (String, String)
                if let engine {
                    if let result = try? await engine.snapshotHTML(for: sreq.url) { (html, text) = result } else { (html, text) = ("", sreq.url) }
                } else {
                    (html, text) = ("<html><body><h1>\(sreq.url)</h1></body></html>", sreq.url)
                }
                let now = Date()
                let page = APIModels.Snapshot.Page(
                    uri: sreq.url,
                    finalUrl: sreq.url,
                    fetchedAt: now.iso8601String,
                    status: 200,
                    contentType: "text/html",
                    navigation: .init(ttfbMs: nil, loadMs: nil)
                )
                let apiSnap = APIModels.Snapshot(
                    snapshotId: sid,
                    page: page,
                    rendered: .init(html: html, text: text, meta: nil),
                    network: nil,
                    diagnostics: []
                )
                // Store artifact for export compatibility
                let store = sreq.storeArtifacts ?? true
                if store { await service.store(snapshot: .init(id: sid, url: sreq.url, renderedHTML: html, renderedText: text)) }
                let resp = APIModels.SnapshotResponse(snapshot: apiSnap)
                if let data = try? JSONEncoder().encode(resp) {
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
                }
                return HTTPResponse(status: 200)
            }
            return HTTPResponse(status: 400)
        case ("POST", ["v1", "analyze"]):
            if let areq = try? JSONDecoder().decode(APIModels.AnalyzeRequest.self, from: req.body) {
                let snap: SemanticMemoryService.Snapshot?
                if let s = areq.snapshot { snap = .init(id: s.snapshotId, url: s.page.uri, renderedHTML: s.rendered.html, renderedText: s.rendered.text) }
                else if let sid = areq.snapshotRef?.snapshotId { snap = await service.loadSnapshot(id: sid) }
                else { snap = nil }
                guard let snap else { return HTTPResponse(status: 400) }
                let fid = UUID().uuidString
                let blocks = HTMLParser().parseBlocks(from: snap.renderedHTML)
                let apiBlocks: [APIModels.Analysis.Block] = blocks.map { .init(id: $0.id, kind: $0.kind, level: nil, text: $0.text, span: nil, table: $0.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }) }
                let analysis = APIModels.Analysis(
                    envelope: .init(id: fid, source: .init(uri: snap.url, fetchedAt: Date().iso8601String), contentType: "text/html", language: "en", bytes: snap.renderedHTML.utf8.count, diagnostics: []),
                    blocks: apiBlocks,
                    semantics: .init(outline: nil, entities: [], claims: [], relations: []),
                    summaries: .init(abstract: nil, keyPoints: nil, tl__dr: nil),
                    provenance: .init(pipeline: "semantic-browser@0.2", model: nil)
                )
                // Store a FullAnalysis for internal indexing/export
                let full = SemanticMemoryService.FullAnalysis(
                    envelope: .init(id: fid, source: .init(uri: snap.url), contentType: "text/html", language: "en"),
                    blocks: blocks,
                    semantics: .init(entities: [])
                )
                await service.store(analysis: full)
                if let data = try? JSONEncoder().encode(analysis) { return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data) }
                return HTTPResponse(status: 200)
            }
            return HTTPResponse(status: 400)
        case ("POST", ["v1", "browse"]):
            if let breq = try? JSONDecoder().decode(APIModels.BrowseRequest.self, from: req.body) {
                let sid = UUID().uuidString
                let (html, text): (String, String)
                if let engine, let result = try? await engine.snapshotHTML(for: breq.url) { (html, text) = result } else { (html, text) = ("<html><body><h1>\(breq.url)</h1></body></html>", breq.url) }
                await service.store(snapshot: .init(id: sid, url: breq.url, renderedHTML: html, renderedText: text))
                let now = Date()
                let snap = APIModels.Snapshot(
                    snapshotId: sid,
                    page: .init(uri: breq.url, finalUrl: breq.url, fetchedAt: now.iso8601String, status: 200, contentType: "text/html", navigation: .init(ttfbMs: nil, loadMs: nil)),
                    rendered: .init(html: html, text: text, meta: nil),
                    network: nil,
                    diagnostics: []
                )
                // Analyze
                let fid = UUID().uuidString
                let blocks = HTMLParser().parseBlocks(from: html)
                let apiBlocks: [APIModels.Analysis.Block] = blocks.map { .init(id: $0.id, kind: $0.kind, level: nil, text: $0.text, span: nil, table: $0.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }) }
                let analysis = APIModels.Analysis(
                    envelope: .init(id: fid, source: .init(uri: breq.url, fetchedAt: now.iso8601String), contentType: "text/html", language: "en", bytes: html.utf8.count, diagnostics: []),
                    blocks: apiBlocks,
                    semantics: .init(outline: nil, entities: [], claims: [], relations: []),
                    summaries: .init(abstract: nil, keyPoints: nil, tl__dr: nil),
                    provenance: .init(pipeline: "semantic-browser@0.2", model: nil)
                )
                // Store internal analysis
                let full = SemanticMemoryService.FullAnalysis(
                    envelope: .init(id: fid, source: .init(uri: breq.url), contentType: "text/html", language: "en"),
                    blocks: blocks,
                    semantics: .init(entities: [])
                )
                await service.store(analysis: full)
                // Optionally index
                var indexRes: APIModels.IndexResult? = nil
                if breq.index?.enabled ?? true {
                    let res = await service.ingest(full: full)
                    indexRes = .init(pagesUpserted: res.pagesUpserted, segmentsUpserted: res.segmentsUpserted, entitiesUpserted: res.entitiesUpserted, tablesUpserted: res.tablesUpserted)
                }
                let resp = APIModels.BrowseResponse(snapshot: snap, analysis: analysis, index: indexRes)
                if let data = try? JSONEncoder().encode(resp) {
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
            let params = qp(req.path)
            guard let pageId = params["pageId"], let format = params["format"] else { return HTTPResponse(status: 400) }
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
                let tables = a.blocks.compactMap { $0.table }
                if tables.isEmpty { return HTTPResponse(status: 404) }
                var csv = ""
                for (i, table) in tables.enumerated() {
                    if i > 0 { csv += "
" }
                    if let cols = table.columns, !cols.isEmpty { csv += cols.joined(separator: ",") + "
" }
                    for row in table.rows { csv += row.joined(separator: ",") + "
" }
                }
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/csv"], body: Data(csv.utf8))
            }
            if format == "summary.md", let a = await service.loadAnalysis(id: pageId) {
                var md = "# Summary

"
                if let title = a.blocks.first(where: { $0.kind == "heading" })?.text { md += "**Title:** \(title)

" }
                if let ents = a.semantics?.entities, !ents.isEmpty {
                    md += "**Entities:**
" + ents.map{ "- \($0.name) (\($0.type))" }.joined(separator: "
") + "

"
                }
                md += "**Blocks:** \(a.blocks.count)

"
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/markdown"], body: Data(md.utf8))
            }
            return HTTPResponse(status: 404)
        default:
            return HTTPResponse(status: 404)
        }
    }
}

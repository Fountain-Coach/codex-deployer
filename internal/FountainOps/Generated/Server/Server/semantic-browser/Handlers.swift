import Foundation
import SBCore

public struct Handlers {
    private let navigator: URLNavigator
    private let dissector: Dissector
    private let indexer: TypesenseIndexer
    private let typesense: TypesenseService?
    private let sb: SB

    public init(
        navigator: URLNavigator = URLNavigator(),
        dissector: Dissector = Dissector(),
        indexer: TypesenseIndexer = TypesenseIndexer(),
        typesense: TypesenseService? = try? TypesenseService()
    ) {
        self.navigator = navigator
        self.dissector = dissector
        self.indexer = indexer
        self.typesense = typesense
        self.sb = SB(navigator: navigator, dissector: dissector, indexer: indexer, store: nil)
    }

    // MARK: - Query
    public func querypages(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Response: Codable { let total: Int; let items: [PageDoc] }
        guard let ts = typesense else {
            let data = try JSONEncoder().encode(Response(total: 0, items: []))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }

        let comps = URLComponents(string: request.path)
        var params: [String: Any] = ["q": "*", "query_by": "title"]
        var limit = 20
        var offset = 0
        var filters: [String] = []
        for item in comps?.queryItems ?? [] {
            switch item.name {
            case "q": params["q"] = item.value ?? "*"
            case "host": if let v = item.value { filters.append("host:=\(v)") }
            case "lang": if let v = item.value { filters.append("lang:=\(v)") }
            case "after": if let v = item.value { filters.append("fetchedAt:>\(v)") }
            case "before": if let v = item.value { filters.append("fetchedAt:<\(v)") }
            case "limit": limit = Int(item.value ?? "") ?? limit
            case "offset": offset = Int(item.value ?? "") ?? offset
            default: break
            }
        }
        params["per_page"] = limit
        params["page"] = offset / limit + 1
        if !filters.isEmpty { params["filter_by"] = filters.joined(separator: " && ") }

        let json = try JSONSerialization.data(withJSONObject: params, options: [])
        let paramStr = String(data: json, encoding: .utf8)!
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "{}"
        let result = try await ts.search(collection: "pages", parameters: paramStr)

        var items: [PageDoc] = []
        for hit in result.hits {
            let docFlat = hit.document.reduce(into: [String: String]()) { acc, kv in
                if let v = kv.value.values.first { acc[kv.key] = v }
            }
            if let data = try? JSONSerialization.data(withJSONObject: docFlat),
               let doc = try? JSONDecoder().decode(PageDoc.self, from: data) {
                items.append(doc)
            }
        }
        let payload = try JSONEncoder().encode(Response(total: result.found, items: items))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func browseanddissect(_ request: HTTPRequest, body: BrowseRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let url: URL; let wait: WaitPolicy; let mode: DissectionMode; let index: IndexOptions? }
        struct Resp: Codable { let snapshot: Snapshot; let analysis: Analysis?; let index: IndexResult? }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let (snap, analysis, result) = try await sb.browseAndDissect(url: req.url, wait: req.wait, mode: req.mode, index: req.index)
        let payload = try JSONEncoder().encode(Resp(snapshot: snap, analysis: analysis, index: result))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func snapshotonly(_ request: HTTPRequest, body: SnapshotRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let url: URL; let wait: WaitPolicy }
        struct Resp: Codable { let snapshot: Snapshot }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let snap = try await navigator.snapshot(url: req.url, wait: req.wait, store: nil)
        let payload = try JSONEncoder().encode(Resp(snapshot: snap))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func health(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Health: Codable {
            let status = "ok"
            let version = "0.0.1"
            let browserPool = ["capacity": 0, "inUse": 0]
        }
        let data = try JSONEncoder().encode(Health())
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func queryentities(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Response: Codable { let total: Int; let items: [EntityDoc] }
        guard let ts = typesense else {
            let data = try JSONEncoder().encode(Response(total: 0, items: []))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }

        let comps = URLComponents(string: request.path)
        var params: [String: Any] = ["q": "*", "query_by": "name"]
        var limit = 20
        var offset = 0
        var filters: [String] = []
        for item in comps?.queryItems ?? [] {
            switch item.name {
            case "q": params["q"] = item.value ?? "*"
            case "type": if let v = item.value { filters.append("type:=\(v)") }
            case "limit": limit = Int(item.value ?? "") ?? limit
            case "offset": offset = Int(item.value ?? "") ?? offset
            default: break
            }
        }
        params["per_page"] = limit
        params["page"] = offset / limit + 1
        if !filters.isEmpty { params["filter_by"] = filters.joined(separator: " && ") }

        let json = try JSONSerialization.data(withJSONObject: params, options: [])
        let paramStr = String(data: json, encoding: .utf8)!
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "{}"
        let result = try await ts.search(collection: "entities", parameters: paramStr)

        var items: [EntityDoc] = []
        for hit in result.hits {
            let docFlat = hit.document.reduce(into: [String: String]()) { acc, kv in
                if let v = kv.value.values.first { acc[kv.key] = v }
            }
            if let data = try? JSONSerialization.data(withJSONObject: docFlat),
               let doc = try? JSONDecoder().decode(EntityDoc.self, from: data) {
                items.append(doc)
            }
        }
        let payload = try JSONEncoder().encode(Response(total: result.found, items: items))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func indexanalysis(_ request: HTTPRequest, body: IndexRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let analysis: Analysis; let options: IndexOptions }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let result = try await indexer.upsert(analysis: req.analysis, options: req.options)
        let data = try JSONEncoder().encode(result)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func exportartifacts(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        guard let ts = typesense else { return HTTPResponse(status: 404) }
        let comps = URLComponents(string: request.path)
        var pageId: String?
        var format: String?
        for item in comps?.queryItems ?? [] {
            switch item.name {
            case "pageId": pageId = item.value
            case "format": format = item.value
            default: break
            }
        }
        guard let pid = pageId, let fmt = format else { return HTTPResponse(status: 400) }
        do {
            let pageData = try await ts.getDocument(collection: "pages", id: pid)
            let page = try? JSONDecoder().decode(PageDoc.self, from: pageData)
            guard let url = page?.url else { return HTTPResponse(status: 404) }

            let snap = try await navigator.snapshot(
                url: url,
                wait: WaitPolicy(strategy: .domContentLoaded),
                store: nil
            )

            var headers: [String: String] = [:]
            var body = Data()
            var analysis: Analysis?
            switch fmt {
            case "snapshot.html":
                headers["Content-Type"] = "text/html"
                body = snap.rendered.html.data(using: .utf8) ?? Data()
            case "snapshot.text":
                headers["Content-Type"] = "text/plain"
                body = snap.rendered.text.data(using: .utf8) ?? Data()
            case "analysis.json", "summary.md", "tables.csv":
                analysis = try await dissector.analyze(from: snap, mode: .standard, store: nil)
                if fmt == "analysis.json" {
                    headers["Content-Type"] = "application/json"
                    body = try JSONEncoder().encode(analysis)
                } else if fmt == "summary.md" {
                    headers["Content-Type"] = "text/markdown"
                    var md = ""
                    if let s = analysis?.summaries {
                        if let abs = s.abstract { md += abs + "\n" }
                        if let points = s.keyPoints, !points.isEmpty {
                            md += points.map { "- \($0)" }.joined(separator: "\n") + "\n"
                        }
                        if let tl = s.tl_dr { md += "\nTL;DR: \(tl)\n" }
                    }
                    body = md.data(using: .utf8) ?? Data()
                } else if fmt == "tables.csv" {
                    headers["Content-Type"] = "text/csv"
                    var lines: [String] = []
                    var first = true
                    for block in analysis?.blocks ?? [] {
                        if let table = block.table {
                            if !first { lines.append("") }
                            first = false
                            if let caption = table.caption { lines.append("# " + caption) }
                            if let cols = table.columns { lines.append(cols.joined(separator: ",")) }
                            for row in table.rows { lines.append(row.joined(separator: ",")) }
                        }
                    }
                    body = lines.joined(separator: "\n").data(using: .utf8) ?? Data()
                }
            default:
                return HTTPResponse(status: 404)
            }
            return HTTPResponse(status: 200, headers: headers, body: body)
        } catch {
            return HTTPResponse(status: 404)
        }
    }

    public func querysegments(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Response: Codable { let total: Int; let items: [SegmentDoc] }
        guard let ts = typesense else {
            let data = try JSONEncoder().encode(Response(total: 0, items: []))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }

        let comps = URLComponents(string: request.path)
        var params: [String: Any] = ["q": "*", "query_by": "text"]
        var limit = 20
        var offset = 0
        var filters: [String] = []
        for item in comps?.queryItems ?? [] {
            switch item.name {
            case "q": params["q"] = item.value ?? "*"
            case "kind": if let v = item.value { filters.append("kind:=\(v)") }
            case "entity": if let v = item.value { filters.append("entities:=[\(v)]") }
            case "limit": limit = Int(item.value ?? "") ?? limit
            case "offset": offset = Int(item.value ?? "") ?? offset
            default: break
            }
        }
        params["per_page"] = limit
        params["page"] = offset / limit + 1
        if !filters.isEmpty { params["filter_by"] = filters.joined(separator: " && ") }

        let json = try JSONSerialization.data(withJSONObject: params, options: [])
        let paramStr = String(data: json, encoding: .utf8)!
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "{}"
        let result = try await ts.search(collection: "segments", parameters: paramStr)

        var items: [SegmentDoc] = []
        for hit in result.hits {
            let docFlat = hit.document.reduce(into: [String: String]()) { acc, kv in
                if let v = kv.value.values.first { acc[kv.key] = v }
            }
            if let data = try? JSONSerialization.data(withJSONObject: docFlat),
               let doc = try? JSONDecoder().decode(SegmentDoc.self, from: data) {
                items.append(doc)
            }
        }
        let payload = try JSONEncoder().encode(Response(total: result.found, items: items))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func getpage(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        guard let ts = typesense else { return HTTPResponse(status: 404) }
        let parts = request.path.split(separator: "/")
        guard let id = parts.last.map(String.init) else { return HTTPResponse(status: 404) }
        do {
            let data = try await ts.getDocument(collection: "pages", id: id)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        } catch {
            return HTTPResponse(status: 404)
        }
    }

    public func analyzesnapshot(_ request: HTTPRequest, body: AnalyzeRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let mode: DissectionMode; let snapshot: Snapshot }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let analysis = try await dissector.analyze(from: req.snapshot, mode: req.mode, store: nil)
        let data = try JSONEncoder().encode(analysis)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

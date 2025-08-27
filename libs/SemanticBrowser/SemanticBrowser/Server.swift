import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
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

actor SimpleMetrics {
    private var counts: [String: Int] = [:]
    private var latencies: [String: [Int]] = [:]
    func inc(_ name: String, by n: Int = 1) { counts[name, default: 0] += n }
    func observe(_ name: String, ms: Int) { latencies[name, default: []].append(ms) }
    func renderPrometheus() -> String {
        var out = ""
        for (k,v) in counts { out += "# TYPE \(k) counter\n\(k) \(v)\n" }
        for (k,arr) in latencies {
            let sum = arr.reduce(0,+)
            out += "# TYPE \(k)_ms summary\n\(k)_ms_count \(arr.count)\n\(k)_ms_sum \(sum)\n"
        }
        return out
    }
}

public func makeSemanticKernel(service: SemanticMemoryService, engine: BrowserEngine? = nil, apiKey: String? = nil, limiter: SimpleRateLimiter? = nil, limitPerMinute: Int = 60, requireAPIKey: Bool = false, reqBodyMaxBytes: Int = 1_000_000, reqTimeoutMs: Int = 15_000, metrics: SimpleMetrics? = nil) -> HTTPKernel {
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
    // SSRF allow/deny configuration and DNS cache
    let env = ProcessInfo.processInfo.environment
    func splitList(_ s: String?) -> [String] { (s ?? "").split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }.filter { !$0.isEmpty } }
    let allowList = splitList(env["SB_URL_ALLOWLIST"]) // e.g., "example.com,.trusted.tld"
    let denyList = splitList(env["SB_URL_DENYLIST"])   // e.g., "bad.com,.internal"
    let dnsTTL = max(Int(env["SB_DNS_CACHE_TTL"] ?? "60") ?? 60, 1)
    var dnsCache: [String: (expires: Date, ips: [String])] = [:]

    func withTimeout<T>(ms: Int, _ op: @escaping () async throws -> T) async -> Result<T, Error> {
        do {
            let v = try await withTimeout(seconds: Double(ms)/1000.0, operation: op)
            return .success(v)
        } catch {
            return .failure(error)
        }
    }
    return HTTPKernel { req in
        // API key enforcement
        if requireAPIKey {
            if (req.headers["X-API-Key"] ?? "").isEmpty { return HTTPResponse(status: 401) }
            if let key = apiKey, !key.isEmpty, (req.headers["X-API-Key"] ?? "") != key { return HTTPResponse(status: 401) }
        } else if let apiKey, !apiKey.isEmpty {
            if (req.headers["X-API-Key"] ?? "") != apiKey { return HTTPResponse(status: 401) }
        }
        // Request body size limit for POST
        if req.method == "POST" && req.body.count > reqBodyMaxBytes { return HTTPResponse(status: 413) }
        if let limiter {
            let client = req.headers["X-Forwarded-For"] ?? req.headers["X-Client-Id"] ?? "anonymous"
            let ok = await limiter.allow(id: client, limitPerMinute: limitPerMinute)
            if !ok { return HTTPResponse(status: 429, headers: ["Content-Type": "text/plain"], body: Data("too many requests".utf8)) }
        }
        let pathOnly = req.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? req.path
        let segs = pathOnly.split(separator: "/", omittingEmptySubsequences: true)
        func urlAllowed(_ urlString: String) -> Bool {
            guard let comp = URLComponents(string: urlString), let host = comp.host, let scheme = comp.scheme?.lowercased(), ["http","https"].contains(scheme) else { return false }
            let h = host.lowercased()
            if h == "localhost" { return false }
            // allowlist/denylist host checks
            func hostMatches(_ rule: String, host: String) -> Bool {
                if rule.hasPrefix(".") { return host == String(rule.dropFirst()) || host.hasSuffix(rule) }
                return host == rule
            }
            if !allowList.isEmpty && !allowList.contains(where: { hostMatches($0, host: h) }) { return false }
            if denyList.contains(where: { hostMatches($0, host: h) }) { return false }
            // IPv4 checks
            func isPrivateIPv4(_ parts: [Int]) -> Bool {
                if parts[0] == 10 { return true }
                if parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31 { return true }
                if parts[0] == 192 && parts[1] == 168 { return true }
                if parts[0] == 127 { return true }
                if parts[0] == 169 && parts[1] == 254 { return true }
                if parts[0] == 0 { return true }
                return false
            }
            if h.split(separator: ".").count == 4, let octets = h.split(separator: ".").compactMap({ Int($0) }), octets.count == 4 {
                if octets.contains(where: { $0 < 0 || $0 > 255 }) { return false }
                if isPrivateIPv4(octets) { return false }
            }
            // IPv6 simple blocklist
            if h.contains(":") {
                let v6 = h
                if v6 == "::1" { return false }
                if v6.hasPrefix("fe80:") { return false } // link-local
                if v6.hasPrefix("fc") || v6.hasPrefix("fd") { return false } // unique local
                if v6 == "::" { return false }
            }
            // DNS resolve and block private/loopback
            func resolveIPs(_ host: String) -> [String] {
                if let entry = dnsCache[host], entry.expires > Date() { return entry.ips }
                var hints = addrinfo(ai_flags: 0, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM, ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
                var res: UnsafeMutablePointer<addrinfo>? = nil
                let rc = getaddrinfo(host, nil, &hints, &res)
                guard rc == 0, let first = res else { return [] }
                defer { freeaddrinfo(first) }
                var out: [String] = []
                var p: UnsafeMutablePointer<addrinfo>? = first
                while let cur = p {
                    if let sa = cur.pointee.ai_addr {
                        var hostbuf = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(sa, socklen_t(cur.pointee.ai_addrlen), &hostbuf, socklen_t(hostbuf.count), nil, 0, NI_NUMERICHOST) == 0 {
                            out.append(String(cString: hostbuf))
                        }
                    }
                    p = cur.pointee.ai_next
                }
                dnsCache[host] = (expires: Date().addingTimeInterval(TimeInterval(dnsTTL)), ips: out)
                return out
            }
            func isPrivateIPv6(_ ip: String) -> Bool {
                let low = ip.lowercased()
                if low == "::1" || low == "::" { return true }
                if low.hasPrefix("fe80:") { return true } // link-local
                if low.hasPrefix("fc") || low.hasPrefix("fd") { return true } // unique local
                return false
            }
            for ip in resolveIPs(h) {
                if ip.contains(":") { if isPrivateIPv6(ip) { return false } }
                else {
                    let parts = ip.split(separator: ".").compactMap { Int($0) }
                    if parts.count == 4 && isPrivateIPv4(parts) { return false }
                }
            }
            return true
        }

        switch (req.method, segs) {
        case ("GET", ["v1", "health"]):
            let body = try? JSONSerialization.data(withJSONObject: ["status": "ok", "version": "0.2.0", "browserPool": ["capacity": 0, "inUse": 0]])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: body ?? Data())
        case ("GET", ["v1", "admin", "healthx"]):
            // Verbose, non-spec health
            var allowed: Set<String> = [
                "text/html", "text/plain", "text/css",
                "application/json", "application/javascript", "text/javascript"
            ]
            if let raw = env["SB_NET_BODY_MIME_ALLOW"], !raw.isEmpty {
                for m in raw.split(separator: ",") { allowed.insert(String(m).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) }
            }
            let maxBodies = max(Int(env["SB_NET_BODY_MAX_COUNT"] ?? "20") ?? 20, 0)
            let maxBytes = max(Int(env["SB_NET_BODY_MAX_BYTES"] ?? "16384") ?? 16384, 512)
            let maxTotal = max(Int(env["SB_NET_BODY_TOTAL_MAX_BYTES"] ?? "131072") ?? 131072, maxBytes)
            let verbose: [String: Any] = [
                "status": "ok",
                "version": "0.2.0",
                "browserPool": ["capacity": 0, "inUse": 0],
                "capture": [
                    "allowedMIMEs": Array(allowed).sorted(),
                    "maxBodies": maxBodies,
                    "maxBodyBytes": maxBytes,
                    "maxTotalBytes": maxTotal
                ],
                "ssrf": [
                    "allowList": allowList,
                    "denyList": denyList,
                    "dnsCacheTTL": dnsTTL
                ]
            ]
            let body = try? JSONSerialization.data(withJSONObject: verbose)
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
            let t0 = Date()
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
                    if let m = metrics { await m.inc("index_requests_total"); await m.observe("index_latency", ms: Int(Date().timeIntervalSince(t0)*1000)) }
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
                }
                return HTTPResponse(status: 200)
            } else if let reqObj = try? JSONDecoder().decode(SemanticMemoryService.IndexRequest.self, from: req.body) {
                let result = await service.ingest(reqObj)
                if let data = try? JSONEncoder().encode(result) { if let m = metrics { await m.inc("index_requests_total"); await m.observe("index_latency", ms: Int(Date().timeIntervalSince(t0)*1000)) }; return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data) }
                return HTTPResponse(status: 200)
            } else if let full = try? JSONDecoder().decode(SemanticMemoryService.FullAnalysis.self, from: req.body) {
                let result = await service.ingest(full: full)
                if let data = try? JSONEncoder().encode(result) { if let m = metrics { await m.inc("index_requests_total"); await m.observe("index_latency", ms: Int(Date().timeIntervalSince(t0)*1000)) }; return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data) }
                return HTTPResponse(status: 200)
            } else {
                if let m = metrics { await m.inc("index_requests_error_total") }
                return HTTPResponse(status: 400)
            }
        case ("POST", ["v1", "snapshot"]):
            let t0 = Date()
            if let sreq = try? JSONDecoder().decode(APIModels.SnapshotRequest.self, from: req.body) {
                // SSRF guard
                guard urlAllowed(sreq.url) else {
                    let reason = ["code": "invalid_url", "message": "URL not allowed"]
                    let data = try? JSONSerialization.data(withJSONObject: reason)
                    return HTTPResponse(status: 400, headers: ["Content-Type": "application/json", "X-URL-Block-Reason": "policy"], body: data ?? Data())
                }
                let sid = UUID().uuidString
                // Per-request capture overrides via headers
                func parseSet(_ s: String?) -> Set<String>? { guard let s, !s.isEmpty else { return nil }; return Set(s.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) }
                let cap = CaptureOptions(
                    allowedMIMEs: parseSet(req.headers["X-Capture-Mimes"]),
                    maxBodies: Int(req.headers["X-Capture-Body-Max-Count"] ?? ""),
                    maxBodyBytes: Int(req.headers["X-Capture-Body-Max-Bytes"] ?? ""),
                    maxTotalBytes: Int(req.headers["X-Capture-Body-Total-Bytes"] ?? "")
                )
                let snapRes: SnapshotResult
                if let engine, let res = try? await engine.snapshot(for: sreq.url, wait: sreq.wait, capture: cap) { snapRes = res } else { snapRes = SnapshotResult(html: "<html><body><h1>\(sreq.url)</h1></body></html>", text: sreq.url, finalURL: sreq.url, loadMs: nil, network: nil) }
                let now = Date()
                let page = APIModels.Snapshot.Page(
                    uri: sreq.url,
                    finalUrl: snapRes.finalURL,
                    fetchedAt: now.iso8601String,
                    status: snapRes.pageStatus ?? 200,
                    contentType: (snapRes.pageContentType ?? "text/html"),
                    navigation: .init(ttfbMs: nil, loadMs: snapRes.loadMs)
                )
                let apiSnap = APIModels.Snapshot(
                    snapshotId: sid,
                    page: page,
                    rendered: .init(html: snapRes.html, text: snapRes.text, meta: nil),
                    network: (snapRes.network.map { APIModels.Snapshot.Network(requests: $0) }) ?? nil,
                    diagnostics: []
                )
                // Store artifact for export compatibility
                let store = sreq.storeArtifacts ?? true
                if store { await service.store(snapshot: .init(id: sid, url: sreq.url, renderedHTML: snapRes.html, renderedText: snapRes.text)) }
                let resp = APIModels.SnapshotResponse(snapshot: apiSnap)
                if let data = try? JSONEncoder().encode(resp) {
                    // Build capture headers
                    var headers = ["Content-Type": "application/json"]
                    // effective capture values mirror CDP logic
                    var allowedEff: Set<String> = [
                        "text/html", "text/plain", "text/css",
                        "application/json", "application/javascript", "text/javascript"
                    ]
                    if let raw = env["SB_NET_BODY_MIME_ALLOW"], !raw.isEmpty {
                        for m in raw.split(separator: ",") { allowedEff.insert(String(m).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) }
                    }
                    if let m = cap.allowedMIMEs { allowedEff.formUnion(m.map { $0.lowercased() }) }
                    let maxBodiesEff = max(cap.maxBodies ?? (Int(env["SB_NET_BODY_MAX_COUNT"] ?? "20") ?? 20), 0)
                    let maxBytesEff = max(cap.maxBodyBytes ?? (Int(env["SB_NET_BODY_MAX_BYTES"] ?? "16384") ?? 16384), 512)
                    let maxTotalEff = max(cap.maxTotalBytes ?? (Int(env["SB_NET_BODY_TOTAL_MAX_BYTES"] ?? "131072") ?? 131072), maxBytesEff)
                    headers["X-Capture-Allowed-MIMEs"] = Array(allowedEff).sorted().joined(separator: ",")
                    headers["X-Capture-Body-Max-Count"] = String(maxBodiesEff)
                    headers["X-Capture-Body-Max-Bytes"] = String(maxBytesEff)
                    headers["X-Capture-Body-Total-Bytes"] = String(maxTotalEff)
                    if let m = metrics { await m.inc("snapshot_requests_total"); await m.observe("snapshot_latency", ms: Int(Date().timeIntervalSince(t0)*1000)) }
                    return HTTPResponse(status: 200, headers: headers, body: data)
                }
                return HTTPResponse(status: 200)
            }
            if let m = metrics { await m.inc("snapshot_requests_error_total") }
            return HTTPResponse(status: 400)
        case ("POST", ["v1", "analyze"]):
            let t0 = Date()
            if let areq = try? JSONDecoder().decode(APIModels.AnalyzeRequest.self, from: req.body) {
                let snap: SemanticMemoryService.Snapshot?
                if let s = areq.snapshot { snap = .init(id: s.snapshotId, url: s.page.uri, renderedHTML: s.rendered.html, renderedText: s.rendered.text) }
                else if let sid = areq.snapshotRef?.snapshotId { snap = await service.loadSnapshot(id: sid) }
                else { snap = nil }
                guard let snap else { return HTTPResponse(status: 400) }
                let fid = UUID().uuidString
                let blocks = HTMLParser().parseBlocks(from: snap.renderedHTML)
                let fullText = snap.renderedText
                var cursor = 0
                var apiBlocks: [APIModels.Analysis.Block] = []
                for b in blocks {
                    let t = b.text
                    if let range = fullText.range(of: t, options: [], range: fullText.index(fullText.startIndex, offsetBy: cursor)..<fullText.endIndex) {
                        let start = fullText.distance(from: fullText.startIndex, to: range.lowerBound)
                        let end = start + t.count
                        cursor = end
                        apiBlocks.append(.init(id: b.id, kind: b.kind, level: nil, text: b.text, span: [start, end], table: b.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }))
                    } else {
                        apiBlocks.append(.init(id: b.id, kind: b.kind, level: nil, text: b.text, span: nil, table: b.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }))
                    }
                }
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
                await service.store(analysis: full, forSnapshotId: snap.id)
                if let data = try? JSONEncoder().encode(analysis) { if let m = metrics { await m.inc("analyze_requests_total"); await m.observe("analyze_latency", ms: Int(Date().timeIntervalSince(t0)*1000)) }; return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data) }
                return HTTPResponse(status: 200)
            }
            if let m = metrics { await m.inc("analyze_requests_error_total") }
            return HTTPResponse(status: 400)
        case ("POST", ["v1", "browse"]):
            let t0 = Date()
            if let breq = try? JSONDecoder().decode(APIModels.BrowseRequest.self, from: req.body) {
                guard urlAllowed(breq.url) else { return HTTPResponse(status: 400, headers: ["Content-Type": "application/json"], body: Data("{\"code\":\"invalid_url\",\"message\":\"URL not allowed\"}".utf8)) }
                let sid = UUID().uuidString
                // Per-request capture overrides via headers
                func parseSet(_ s: String?) -> Set<String>? { guard let s, !s.isEmpty else { return nil }; return Set(s.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) }
                let cap = CaptureOptions(
                    allowedMIMEs: parseSet(req.headers["X-Capture-Mimes"]),
                    maxBodies: Int(req.headers["X-Capture-Body-Max-Count"] ?? ""),
                    maxBodyBytes: Int(req.headers["X-Capture-Body-Max-Bytes"] ?? ""),
                    maxTotalBytes: Int(req.headers["X-Capture-Body-Total-Bytes"] ?? "")
                )
                let snapRes: SnapshotResult
                if let engine, let res = try? await engine.snapshot(for: breq.url, wait: breq.wait, capture: cap) { snapRes = res } else { snapRes = SnapshotResult(html: "<html><body><h1>\(breq.url)</h1></body></html>", text: breq.url, finalURL: breq.url, loadMs: nil, network: nil) }
                await service.store(snapshot: .init(id: sid, url: breq.url, renderedHTML: snapRes.html, renderedText: snapRes.text))
                let now = Date()
                let snap = APIModels.Snapshot(
                    snapshotId: sid,
                    page: .init(uri: breq.url, finalUrl: snapRes.finalURL, fetchedAt: now.iso8601String, status: snapRes.pageStatus ?? 200, contentType: (snapRes.pageContentType ?? "text/html"), navigation: .init(ttfbMs: nil, loadMs: snapRes.loadMs)),
                    rendered: .init(html: snapRes.html, text: snapRes.text, meta: nil),
                    network: (snapRes.network.map { APIModels.Snapshot.Network(requests: $0) }) ?? nil,
                    diagnostics: []
                )
                // Analyze
                let fid = UUID().uuidString
                let blocks = HTMLParser().parseBlocks(from: snapRes.html)
                let fullText = snapRes.text
                var cursor = 0
                var apiBlocks: [APIModels.Analysis.Block] = []
                for b in blocks {
                    let t = b.text
                    if let range = fullText.range(of: t, options: [], range: fullText.index(fullText.startIndex, offsetBy: cursor)..<fullText.endIndex) {
                        let start = fullText.distance(from: fullText.startIndex, to: range.lowerBound)
                        let end = start + t.count
                        cursor = end
                        apiBlocks.append(.init(id: b.id, kind: b.kind, level: nil, text: b.text, span: [start, end], table: b.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }))
                    } else {
                        apiBlocks.append(.init(id: b.id, kind: b.kind, level: nil, text: b.text, span: nil, table: b.table.map { .init(caption: $0.caption, columns: $0.columns, rows: $0.rows) }))
                    }
                }
                let analysis = APIModels.Analysis(
                    envelope: .init(id: fid, source: .init(uri: breq.url, fetchedAt: now.iso8601String), contentType: "text/html", language: "en", bytes: snapRes.html.utf8.count, diagnostics: []),
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
                await service.store(analysis: full, forSnapshotId: sid)
                // Optionally index
                var indexRes: APIModels.IndexResult? = nil
                if breq.index?.enabled ?? true {
                    let res = await service.ingest(full: full)
                    indexRes = .init(pagesUpserted: res.pagesUpserted, segmentsUpserted: res.segmentsUpserted, entitiesUpserted: res.entitiesUpserted, tablesUpserted: res.tablesUpserted)
                }
                let resp = APIModels.BrowseResponse(snapshot: snap, analysis: analysis, index: indexRes)
                if let data = try? JSONEncoder().encode(resp) {
                    // Build capture headers
                    var headers = ["Content-Type": "application/json"]
                    var allowedEff: Set<String> = [
                        "text/html", "text/plain", "text/css",
                        "application/json", "application/javascript", "text/javascript"
                    ]
                    if let raw = env["SB_NET_BODY_MIME_ALLOW"], !raw.isEmpty {
                        for m in raw.split(separator: ",") { allowedEff.insert(String(m).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) }
                    }
                    if let m = cap.allowedMIMEs { allowedEff.formUnion(m.map { $0.lowercased() }) }
                    let maxBodiesEff = max(cap.maxBodies ?? (Int(env["SB_NET_BODY_MAX_COUNT"] ?? "20") ?? 20), 0)
                    let maxBytesEff = max(cap.maxBodyBytes ?? (Int(env["SB_NET_BODY_MAX_BYTES"] ?? "16384") ?? 16384), 512)
                    let maxTotalEff = max(cap.maxTotalBytes ?? (Int(env["SB_NET_BODY_TOTAL_MAX_BYTES"] ?? "131072") ?? 131072), maxBytesEff)
                    headers["X-Capture-Allowed-MIMEs"] = Array(allowedEff).sorted().joined(separator: ",")
                    headers["X-Capture-Body-Max-Count"] = String(maxBodiesEff)
                    headers["X-Capture-Body-Max-Bytes"] = String(maxBytesEff)
                    headers["X-Capture-Body-Total-Bytes"] = String(maxTotalEff)
                    if let m = metrics { await m.inc("browse_requests_total"); await m.observe("browse_latency", ms: Int(Date().timeIntervalSince(t0)*1000)) }
                    return HTTPResponse(status: 200, headers: headers, body: data)
                }
                return HTTPResponse(status: 200)
            }
            if let m = metrics { await m.inc("browse_requests_error_total") }
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
            if format == "snapshot.html", let snap = await service.resolveSnapshot(byPageId: pageId) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/html"], body: Data(snap.renderedHTML.utf8))
            }
            if format == "snapshot.text", let snap = await service.resolveSnapshot(byPageId: pageId) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data(snap.renderedText.utf8))
            }
            if format == "analysis.json", let a = await service.resolveAnalysis(byPageId: pageId), let data = try? JSONEncoder().encode(a) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            if format == "tables.csv", let a = await service.resolveAnalysis(byPageId: pageId) {
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
            if format == "summary.md", let a = await service.resolveAnalysis(byPageId: pageId) {
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
        case ("GET", ["metrics"]):
            if let m = metrics { let body = Data(await m.renderPrometheus().utf8); return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain; version=0.0.4"], body: body) }
            return HTTPResponse(status: 404)
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

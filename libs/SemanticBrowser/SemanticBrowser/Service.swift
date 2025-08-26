import Foundation

public actor SemanticMemoryService {
    private var pages: [PageDoc] = []
    private var segments: [SegmentDoc] = []
    private var entities: [EntityDoc] = []

    public init() {}

    // Seeding for tests or importers
    public func seed(pages: [PageDoc] = [], segments: [SegmentDoc] = [], entities: [EntityDoc] = []) {
        self.pages.append(contentsOf: pages)
        self.segments.append(contentsOf: segments)
        self.entities.append(contentsOf: entities)
    }

    public func queryPages(q: String?, host: String?, lang: String?, limit: Int, offset: Int) -> (total: Int, items: [PageDoc]) {
        var list = pages
        if let host, !host.isEmpty { list = list.filter { $0.host == host } }
        if let lang, !lang.isEmpty { list = list.filter { $0.lang?.lowercased() == lang.lowercased() } }
        if let q, !q.isEmpty {
            let n = q.lowercased()
            list = list.filter { ($0.title ?? "").lowercased().contains(n) || ($0.url).lowercased().contains(n) }
        }
        let total = list.count
        let slice = Array(list.dropFirst(min(offset, total)).prefix(limit))
        return (total, slice)
    }

    public func querySegments(q: String?, kind: String?, entity: String?, limit: Int, offset: Int) -> (total: Int, items: [SegmentDoc]) {
        var list = segments
        if let kind, !kind.isEmpty { list = list.filter { $0.kind == kind } }
        if let entity, !entity.isEmpty { list = list.filter { ($0.entities ?? []).contains(entity) } }
        if let q, !q.isEmpty { let n = q.lowercased(); list = list.filter { $0.text.lowercased().contains(n) } }
        let total = list.count
        let slice = Array(list.dropFirst(min(offset, total)).prefix(limit))
        return (total, slice)
    }

    public func queryEntities(q: String?, type: String?, limit: Int, offset: Int) -> (total: Int, items: [EntityDoc]) {
        var list = entities
        if let type, !type.isEmpty { list = list.filter { $0.type == type } }
        if let q, !q.isEmpty { let n = q.lowercased(); list = list.filter { $0.name.lowercased().contains(n) } }
        let total = list.count
        let slice = Array(list.dropFirst(min(offset, total)).prefix(limit))
        return (total, slice)
    }

    // MARK: - Ingest (Index)
    public struct IndexRequest: Codable, Sendable {
        public let analysis: IngestAnalysis
        public init(analysis: IngestAnalysis) { self.analysis = analysis }
    }
    public struct IngestAnalysis: Codable, Sendable {
        public let page: PageDoc
        public let segments: [SegmentDoc]?
        public let entities: [EntityDoc]?
        public init(page: PageDoc, segments: [SegmentDoc]? = nil, entities: [EntityDoc]? = nil) {
            self.page = page; self.segments = segments; self.entities = entities
        }
    }
    public struct IndexResult: Codable, Sendable {
        public let pagesUpserted: Int
        public let segmentsUpserted: Int
        public let entitiesUpserted: Int
        public let tablesUpserted: Int
    }

    public func ingest(_ req: IndexRequest) -> IndexResult {
        var pUp = 0, sUp = 0, eUp = 0
        // Upsert page by id
        if let idx = pages.firstIndex(where: { $0.id == req.analysis.page.id }) {
            pages[idx] = req.analysis.page
        } else {
            pages.append(req.analysis.page)
        }
        pUp = 1
        if let segs = req.analysis.segments {
            for s in segs {
                if let i = segments.firstIndex(where: { $0.id == s.id }) { segments[i] = s } else { segments.append(s) }
                sUp += 1
            }
        }
        if let ents = req.analysis.entities {
            for e in ents {
                if let i = entities.firstIndex(where: { $0.id == e.id }) { entities[i] = e } else { entities.append(e) }
                eUp += 1
            }
        }
        return IndexResult(pagesUpserted: pUp, segmentsUpserted: sUp, entitiesUpserted: eUp, tablesUpserted: 0)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

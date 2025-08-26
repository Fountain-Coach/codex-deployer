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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


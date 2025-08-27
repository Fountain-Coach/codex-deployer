#if canImport(Typesense)
import Foundation
import Typesense

public final class TypesenseSemanticBackend: SemanticMemoryService.Backend, @unchecked Sendable {
    private let client: Client

    public init(nodes: [String], apiKey: String, debug: Bool = false) {
        let tsNodes = nodes.map { Node(url: $0) }
        let config = Configuration(nodes: tsNodes, apiKey: apiKey, logger: Logger(debugMode: debug))
        self.client = Client(config: config)
        Task { try? await self.ensureCollections() }
    }

    private func ensureCollections() async throws {
        let pageFields = [Field(name: "id", type: "string"), Field(name: "url", type: "string"), Field(name: "host", type: "string"), Field(name: "title", type: "string"), Field(name: "lang", type: "string")]
        _ = try? await client.collections.create(schema: CollectionSchema(name: "pages", fields: pageFields, defaultSortingField: nil))
        let segFields = [Field(name: "id", type: "string"), Field(name: "pageId", type: "string"), Field(name: "kind", type: "string"), Field(name: "text", type: "string"), Field(name: "entities", type: "string[]")]
        _ = try? await client.collections.create(schema: CollectionSchema(name: "segments", fields: segFields, defaultSortingField: nil))
        let entFields = [Field(name: "id", type: "string"), Field(name: "name", type: "string"), Field(name: "type", type: "string")]
        _ = try? await client.collections.create(schema: CollectionSchema(name: "entities", fields: entFields, defaultSortingField: nil))
    }

    public func upsert(page: PageDoc) {
        if let data = try? JSONEncoder().encode(page) {
            Task { _ = try? await client.collection(name: "pages").documents().upsert(document: data) }
        }
    }
    public func upsert(segment: SegmentDoc) {
        if let data = try? JSONEncoder().encode(segment) {
            Task { _ = try? await client.collection(name: "segments").documents().upsert(document: data) }
        }
    }
    public func upsert(entity: EntityDoc) {
        if let data = try? JSONEncoder().encode(entity) {
            Task { _ = try? await client.collection(name: "entities").documents().upsert(document: data) }
        }
    }

    private func totalAndDocs<T: Decodable>(_ res: SearchResult<T>?) -> (Int, [T]) {
        guard let res else { return (0, []) }
        let docs = res.hits?.compactMap { $0.document } ?? []
        var total = docs.count
        if let f = Mirror(reflecting: res as Any).children.first(where: { $0.label == "found" })?.value as? Int { total = f }
        else if let f32 = Mirror(reflecting: res as Any).children.first(where: { $0.label == "found" })?.value as? Int32 { total = Int(f32) }
        return (total, docs)
    }

    public func searchPages(q: String?, host: String?, lang: String?, limit: Int, offset: Int) -> (Int, [PageDoc]) {
        let page = max(offset / max(limit, 1) + 1, 1)
        var filter: [String] = []
        if let host, !host.isEmpty { filter.append("host:=\(host)") }
        if let lang, !lang.isEmpty { filter.append("lang:=\(lang)") }
        let params = SearchParameters(q: (q?.isEmpty == false ? q! : "*"), queryBy: "title,url,host,lang", filterBy: filter.isEmpty ? nil : filter.joined(separator: " && "), page: page, perPage: max(limit, 1))
        let res = try? await client.collection(name: "pages").documents().search(params, for: PageDoc.self)
        return totalAndDocs(res?.0)
    }

    public func searchSegments(q: String?, kind: String?, entity: String?, limit: Int, offset: Int) -> (Int, [SegmentDoc]) {
        let page = max(offset / max(limit, 1) + 1, 1)
        var filter: [String] = []
        if let kind, !kind.isEmpty { filter.append("kind:=\(kind)") }
        if let entity, !entity.isEmpty { filter.append("entities:=[\(entity)]") }
        let params = SearchParameters(q: (q?.isEmpty == false ? q! : "*"), queryBy: "text,kind,entities", filterBy: filter.isEmpty ? nil : filter.joined(separator: " && "), page: page, perPage: max(limit, 1))
        let res = try? await client.collection(name: "segments").documents().search(params, for: SegmentDoc.self)
        return totalAndDocs(res?.0)
    }

    public func searchEntities(q: String?, type: String?, limit: Int, offset: Int) -> (Int, [EntityDoc]) {
        let page = max(offset / max(limit, 1) + 1, 1)
        let filter = (type?.isEmpty == false) ? "type:=\(type!)" : nil
        let params = SearchParameters(q: (q?.isEmpty == false ? q! : "*"), queryBy: "name,type", filterBy: filter, page: page, perPage: max(limit, 1))
        let res = try? await client.collection(name: "entities").documents().search(params, for: EntityDoc.self)
        return totalAndDocs(res?.0)
    }
}
#endif

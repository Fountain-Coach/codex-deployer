import Foundation

#if canImport(Typesense)
import Typesense
#endif

public protocol TypesenseClientLike: Sendable {
    func createCollection(name: String, fields: [(String, String)], defaultSortingField: String?) async throws
    func upsert(collectionName: String, document: Data) async throws
    func exportAll(collectionName: String) async throws -> Data
    func searchFunctions(q: String, filterBy: String?, page: Int, perPage: Int) async throws -> (total: Int, functions: [FunctionModel])
}

#if canImport(Typesense)
extension Client: TypesenseInternalClient {}

public protocol TypesenseInternalClient {}

public final class RealTypesenseClient: TypesenseClientLike, @unchecked Sendable {
    private let client: Client

    public init(nodes: [String], apiKey: String, debug: Bool = false) {
        let tsNodes: [Node] = nodes.map { Node(url: $0) }
        let config = Configuration(nodes: tsNodes, apiKey: apiKey, logger: Logger(debugMode: debug))
        self.client = Client(config: config)
    }

    public init(client: Client) { self.client = client }

    public func createCollection(name: String, fields: [(String, String)], defaultSortingField: String?) async throws {
        let schema = CollectionSchema(
            name: name,
            fields: fields.map { Field(name: $0.0, type: $0.1) },
            defaultSortingField: defaultSortingField
        )
        _ = try await client.collections.create(schema: schema)
    }

    public func upsert(collectionName: String, document: Data) async throws {
        _ = try await client.collection(name: collectionName).documents().upsert(document: document)
    }

    public func exportAll(collectionName: String) async throws -> Data {
        let (data, _) = try await client.collection(name: collectionName).documents().export(options: nil)
        return data ?? Data()
    }

    public func searchFunctions(q: String, filterBy: String?, page: Int, perPage: Int) async throws -> (total: Int, functions: [FunctionModel]) {
        let params = SearchParameters(
            q: q,
            queryBy: "name,description,httpPath,functionId,corpusId",
            filterBy: filterBy,
            page: page,
            perPage: perPage
        )
        let (resultOpt, _) = try await client.collection(name: "functions").documents().search(params, for: FunctionModel.self)
        guard let result = resultOpt else { return (0, []) }
        // Prefer result.found if available; otherwise fall back to hits count
        let hits = result.hits?.compactMap { $0.document } ?? []
        let total: Int
        if let mirrorFound = Mirror(reflecting: result as Any).children.first(where: { $0.label == "found" })?.value as? Int {
            total = mirrorFound
        } else if let mirrorFoundI = Mirror(reflecting: result as Any).children.first(where: { $0.label == "found" })?.value as? Int32 {
            total = Int(mirrorFoundI)
        } else {
            total = hits.count
        }
        return (total, hits)
    }
}
#endif

public final class MockTypesenseClient: TypesenseClientLike, @unchecked Sendable {
    public private(set) var collections: [String: [[String: Any]]] = [:]

    public init() {}

    public func createCollection(name: String, fields: [(String, String)], defaultSortingField: String?) async throws {
        if collections[name] == nil { collections[name] = [] }
    }

    public func upsert(collectionName: String, document: Data) async throws {
        let obj = try JSONSerialization.jsonObject(with: document) as? [String: Any] ?? [:]
        var list = collections[collectionName] ?? []
        // Prefer specific identifiers first to avoid matching corpusId for functions
        let preferredKeys = ["functionId", "baselineId", "reflectionId", "corpusId", "id"]
        let idKey = preferredKeys.first(where: { obj[$0] is String }) ?? obj.keys.first(where: { $0.hasSuffix("Id") || $0 == "id" })
        if let idKey, let id = obj[idKey] as? String, !id.isEmpty {
            if let idx = list.firstIndex(where: { ($0[idKey] as? String) == id }) {
                list[idx] = obj
            } else {
                list.append(obj)
            }
        } else {
            list.append(obj)
        }
        collections[collectionName] = list
    }

    public func exportAll(collectionName: String) async throws -> Data {
        let list = collections[collectionName] ?? []
        // Return JSONL
        let lines = try list.map { try JSONSerialization.data(withJSONObject: $0) }.map { String(data: $0, encoding: .utf8) ?? "{}" }
        return Data(lines.joined(separator: "\n").utf8)
    }

    public func searchFunctions(q: String, filterBy: String?, page: Int, perPage: Int) async throws -> (total: Int, functions: [FunctionModel]) {
        let all = collections["functions"] ?? []
        let needle = q == "*" ? nil : q.lowercased()
        let filtered: [[String: Any]] = all.filter { obj in
            if let fb = filterBy, fb.hasPrefix("corpusId:=") {
                let val = String(fb.dropFirst("corpusId:=".count))
                if (obj["corpusId"] as? String) != val { return false }
            }
            if let needle {
                let fields = ["name","description","httpPath","functionId","corpusId"]
                return fields.contains { key in (obj[key] as? String)?.lowercased().contains(needle) == true }
            }
            return true
        }
        let decoded: [FunctionModel] = try filtered.map { data in
            let d = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(FunctionModel.self, from: d)
        }.sorted { $0.functionId < $1.functionId }
        let start = max((page - 1) * perPage, 0)
        let slice = Array(decoded.dropFirst(min(start, decoded.count)).prefix(perPage))
        return (decoded.count, slice)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

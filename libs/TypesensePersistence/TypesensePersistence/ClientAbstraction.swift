import Foundation

#if canImport(Typesense)
import Typesense
#endif

public protocol TypesenseClientLike {
    func createCollection(name: String, fields: [(String, String)], defaultSortingField: String?) async throws
    func upsert(collectionName: String, document: Data) async throws
    func exportAll(collectionName: String) async throws -> Data
}

#if canImport(Typesense)
extension Client: TypesenseInternalClient {}

public protocol TypesenseInternalClient {}

public final class RealTypesenseClient: TypesenseClientLike {
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
        return data
    }
}
#endif

public final class MockTypesenseClient: TypesenseClientLike {
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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

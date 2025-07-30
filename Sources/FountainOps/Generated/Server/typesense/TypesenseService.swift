import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum TypesenseServiceError: LocalizedError {
    case missingURL
    case missingAPIKey
    case invalidURL(String)

    public var errorDescription: String? {
        switch self {
        case .missingURL: return "TYPESENSE_URL environment variable is not set"
        case .missingAPIKey: return "TYPESENSE_API_KEY environment variable is not set"
        case .invalidURL(let value): return "TYPESENSE_URL is invalid: \(value)"
        }
    }
}

public final actor TypesenseService {
    private let client: APIClient

    public init(environment: [String: String] = ProcessInfo.processInfo.environment,
                session: HTTPSession = URLSession.shared) throws {
        guard let urlString = environment["TYPESENSE_URL"], !urlString.isEmpty else {
            throw TypesenseServiceError.missingURL
        }
        guard let apiKey = environment["TYPESENSE_API_KEY"], !apiKey.isEmpty else {
            throw TypesenseServiceError.missingAPIKey
        }
        guard let url = URL(string: urlString) else {
            throw TypesenseServiceError.invalidURL(urlString)
        }
        self.client = APIClient(baseURL: url, session: session, defaultHeaders: ["X-TYPESENSE-API-KEY": apiKey])
    }

    public func listCollections() async throws -> getCollectionsResponse {
        try await client.send(getCollections())
    }

    public func createCollection(schema: CollectionSchema) async throws -> Data {
        try await client.send(createCollection(body: schema))
    }

    public func getCollection(name: String) async throws -> CollectionResponse {
        try await client.send(getCollection(parameters: .init(collectionname: name)))
    }

    public func deleteCollection(name: String) async throws -> CollectionResponse {
        try await client.send(deleteCollection(parameters: .init(collectionname: name)))
    }

    public func getKeys() async throws -> ApiKeysResponse {
        try await client.send(getKeys())
    }

    public func createKey(schema: ApiKeySchema) async throws -> Data {
        try await client.send(createKey(body: schema))
    }

    public func getKey(id: Int) async throws -> ApiKey {
        try await client.send(getKey(parameters: .init(keyid: id)))
    }

    public func getAliases() async throws -> CollectionAliasesResponse {
        try await client.send(getAliases())
    }

    public func upsertAlias(name: String, schema: CollectionAliasSchema) async throws -> CollectionAlias {
        try await client.send(upsertAlias(parameters: .init(aliasname: name), body: schema))
    }

    public func getAlias(name: String) async throws -> CollectionAlias {
        try await client.send(getAlias(parameters: .init(aliasname: name)))
    }

    public func deleteAlias(name: String) async throws -> CollectionAlias {
        try await client.send(deleteAlias(parameters: .init(aliasname: name)))
    }

    public func search(collection: String, parameters: String) async throws -> SearchResult {
        struct Request: APIRequest {
            typealias Body = NoBody
            typealias Response = SearchResult
            let collection: String
            let parameters: String
            var method: String { "GET" }
            var path: String { "/collections/\(collection)/documents/search?searchParameters=\(parameters)" }
            var body: Body? { nil }
        }
        return try await client.send(Request(collection: collection, parameters: parameters))
    }

    public func debug() async throws -> debugResponse {
        try await client.send(debug())
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

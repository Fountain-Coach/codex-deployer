import Foundation

import TypesenseClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


/// Errors thrown by `TypesenseService` when environment configuration is incomplete.
public enum TypesenseServiceError: LocalizedError {
    case missingURL
    case missingAPIKey
    case invalidURL(String)

    public var errorDescription: String? {
        switch self {
        case .missingURL:
            return "TYPESENSE_URL environment variable is not set"
        case .missingAPIKey:
            return "TYPESENSE_API_KEY environment variable is not set"
        case .invalidURL(let value):
            return "TYPESENSE_URL is invalid: \(value)"
        }
    }
}

/// Thin wrapper over the generated `APIClient` providing common Typesense operations.
public struct TypesenseService {
    private let client: APIClient

    /// Initialize the service using environment variables.
    /// - Parameter session: Custom `HTTPSession` used for testing.
    public init(session: HTTPSession = URLSession.shared) throws {
        let env = ProcessInfo.processInfo.environment
        guard let urlString = env["TYPESENSE_URL"], !urlString.isEmpty else {
            throw TypesenseServiceError.missingURL
        }
        guard let apiKey = env["TYPESENSE_API_KEY"], !apiKey.isEmpty else {
            throw TypesenseServiceError.missingAPIKey
        }
        guard let url = URL(string: urlString) else {
            throw TypesenseServiceError.invalidURL(urlString)
        }
        self.client = APIClient(baseURL: url, bearerToken: apiKey, session: session)
    }

    /// List available collections.
    public func listCollections() async throws -> getCollectionsResponse {
        try await client.send(getCollections())
    }

    /// Search documents within a collection using a minimal query.
    /// - Parameters:
    ///   - collection: Name of the collection.
    ///   - q: Query string.
    ///   - queryBy: Comma separated list of fields to search.
    public func search(collection: String, q: String, queryBy: String) async throws -> SearchResult {
        struct SearchRequest: APIRequest {
            typealias Body = NoBody
            typealias Response = SearchResult
            let collection: String
            let q: String
            let queryBy: String
            var method: String { "GET" }
            var path: String {
                let params = ["q": q, "query_by": queryBy]
                let data = try? JSONEncoder().encode(params)
                let json = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
                let encoded = json.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? json
                return "/collections/\(collection)/documents/search?searchParameters=\(encoded)"
            }
            var body: Body? { nil }
        }
        return try await client.send(SearchRequest(collection: collection, q: q, queryBy: queryBy))
    }

    /// Update an existing collection schema.
    public func updateSchema(collection: String, schema: CollectionUpdateSchema) async throws -> CollectionUpdateSchema {
        struct UpdateRequest: APIRequest {
            typealias Body = CollectionUpdateSchema
            typealias Response = CollectionUpdateSchema
            let collection: String
            let schema: CollectionUpdateSchema
            var method: String { "PATCH" }
            var path: String { "/collections/\(collection)" }
            var body: Body? { schema }
        }
        return try await client.send(UpdateRequest(collection: collection, schema: schema))
    }
}

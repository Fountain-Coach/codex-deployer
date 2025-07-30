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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

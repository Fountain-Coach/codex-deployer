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

    public func indexDocument(collection: String, document: indexDocumentRequest, action: IndexAction? = nil, dirtyValues: DirtyValues? = nil) async throws -> Data {
        try await client.send(indexDocument(parameters: .init(collectionname: collection, action: action, dirtyValues: dirtyValues), body: document))
    }

    public func updateDocuments(collection: String, document: updateDocumentsRequest, parameters: [String: String]? = nil) async throws -> updateDocumentsResponse {
        try await client.send(updateDocuments(parameters: .init(collectionname: collection, updatedocumentsparameters: parameters), body: document))
    }

    public func deleteDocuments(collection: String, parameters: [String: String]? = nil) async throws -> deleteDocumentsResponse {
        try await client.send(deleteDocuments(parameters: .init(collectionname: collection, deletedocumentsparameters: parameters)))
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

    public func deleteKey(id: Int) async throws -> ApiKeyDeleteResponse {
        try await client.send(deleteKey(parameters: .init(keyid: id)))
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

    public func health() async throws -> HealthStatus {
        try await client.send(health())
    }

    public func getSchemaChanges() async throws -> getSchemaChangesResponse {
        try await client.send(getSchemaChanges())
    }

    public func getSearchOverrides(collection: String) async throws -> SearchOverridesResponse {
        try await client.send(getSearchOverrides(parameters: .init(collectionname: collection)))
    }

    public func getSearchOverride(collection: String, id: String) async throws -> SearchOverride {
        try await client.send(getSearchOverride(parameters: .init(collectionname: collection, overrideid: id)))
    }

    public func upsertSearchOverride(collection: String, id: String, schema: SearchOverrideSchema) async throws -> SearchOverride {
        try await client.send(upsertSearchOverride(parameters: .init(collectionname: collection, overrideid: id), body: schema))
    }

    public func deleteSearchOverride(collection: String, id: String) async throws -> SearchOverrideDeleteResponse {
        try await client.send(deleteSearchOverride(parameters: .init(collectionname: collection, overrideid: id)))
    }

    public func getSearchSynonyms(collection: String) async throws -> SearchSynonymsResponse {
        try await client.send(getSearchSynonyms(parameters: .init(collectionname: collection)))
    }

    public func getSearchSynonym(collection: String, id: String) async throws -> SearchSynonym {
        try await client.send(getSearchSynonym(parameters: .init(collectionname: collection, synonymid: id)))
    }

    public func upsertSearchSynonym(collection: String, id: String, schema: SearchSynonymSchema) async throws -> SearchSynonym {
        try await client.send(upsertSearchSynonym(parameters: .init(collectionname: collection, synonymid: id), body: schema))
    }

    public func deleteSearchSynonym(collection: String, id: String) async throws -> SearchSynonymDeleteResponse {
        try await client.send(deleteSearchSynonym(parameters: .init(collectionname: collection, synonymid: id)))
    }

    public func exportDocuments(collection: String, parameters: [String: String]? = nil) async throws -> Data {
        try await client.send(exportDocuments(parameters: .init(collectionname: collection, exportdocumentsparameters: parameters)))
    }

    public func importDocuments(collection: String, data: Data, parameters: [String: String]? = nil) async throws -> Data {
        struct Request: APIRequest {
            typealias Body = NoBody
            typealias Response = Data
            let collection: String
            let parameters: [String: String]?
            var method: String { "POST" }
            var path: String {
                var path = "/collections/\(collection)/documents/import"
                if let params = parameters, !params.isEmpty {
                    let query = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                    path += "?" + query
                }
                return path
            }
            var body: Body? { nil }
        }

        var request = URLRequest(url: client.baseURL.appendingPathComponent(Request(collection: collection, parameters: parameters).path))
        request.httpMethod = "POST"
        for (header, value) in client.defaultHeaders { request.setValue(value, forHTTPHeaderField: header) }
        request.httpBody = data
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        let (respData, _) = try await client.session.data(for: request)
        return respData
    }

    public func getDocument(collection: String, id: String) async throws -> Data {
        try await client.send(getDocument(parameters: .init(collectionname: collection, documentid: id)))
    }

    public func deleteDocument(collection: String, id: String) async throws -> Data {
        try await client.send(deleteDocument(parameters: .init(collectionname: collection, documentid: id)))
    }

    public func retrieveAllConversationModels() async throws -> retrieveAllConversationModelsResponse {
        try await client.send(retrieveAllConversationModels())
    }

    public func createConversationModel(schema: ConversationModelCreateSchema) async throws -> ConversationModelSchema {
        try await client.send(createConversationModel(body: schema))
    }

    public func retrieveConversationModel(id: String) async throws -> ConversationModelSchema {
        try await client.send(retrieveConversationModel(parameters: .init(modelid: id)))
    }

    public func updateConversationModel(id: String, schema: ConversationModelUpdateSchema) async throws -> ConversationModelSchema {
        try await client.send(updateConversationModel(parameters: .init(modelid: id), body: schema))
    }

    public func deleteConversationModel(id: String) async throws -> ConversationModelSchema {
        try await client.send(deleteConversationModel(parameters: .init(modelid: id)))
    }

    public func createAnalyticsEvent(schema: AnalyticsEventCreateSchema) async throws -> Data {
        try await client.send(createAnalyticsEvent(body: schema))
    }

    public func createAnalyticsRule(schema: AnalyticsRuleSchema) async throws -> Data {
        try await client.send(createAnalyticsRule(body: schema))
    }

    public func multiSearch(parameters: String, body: MultiSearchSearchesParameter) async throws -> MultiSearchResult {
        struct Request: APIRequest {
            typealias Body = MultiSearchSearchesParameter
            typealias Response = MultiSearchResult
            let parameters: String
            var body: Body? { bodyParam }
            let bodyParam: Body
            var method: String { "POST" }
            var path: String { "/multi_search?multiSearchParameters=\(parameters)" }
        }
        return try await client.send(Request(parameters: parameters, bodyParam: body))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

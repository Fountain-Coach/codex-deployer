import Foundation

public struct queryEntitiesParameters: Codable {
    public var q: String?
    public var type: String?
    public var limit: Int?
    public var offset: Int?
}

public struct queryEntities: APIRequest {
    public typealias Body = NoBody
    public typealias Response = queryEntitiesResponse
    public var method: String { "GET" }
    public var parameters: queryEntitiesParameters
    public var path: String {
        var path = "/v1/entities"
        var query: [String] = []
        if let value = parameters.q { query.append("q=\(value)") }
        if let value = parameters.type { query.append("type=\(value)") }
        if let value = parameters.limit { query.append("limit=\(value)") }
        if let value = parameters.offset { query.append("offset=\(value)") }
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: queryEntitiesParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation

public struct querySegmentsParameters: Codable {
    public var q: String?
    public var kind: String?
    public var entity: String?
    public var limit: Int?
    public var offset: Int?
}

public struct querySegments: APIRequest {
    public typealias Body = NoBody
    public typealias Response = querySegmentsResponse
    public var method: String { "GET" }
    public var parameters: querySegmentsParameters
    public var path: String {
        var path = "/v1/segments"
        var query: [String] = []
        if let value = parameters.q { query.append("q=\(value)") }
        if let value = parameters.kind { query.append("kind=\(value)") }
        if let value = parameters.entity { query.append("entity=\(value)") }
        if let value = parameters.limit { query.append("limit=\(value)") }
        if let value = parameters.offset { query.append("offset=\(value)") }
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: querySegmentsParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

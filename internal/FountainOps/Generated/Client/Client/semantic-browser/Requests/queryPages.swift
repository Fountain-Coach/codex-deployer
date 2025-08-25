import Foundation

public struct queryPagesParameters: Codable {
    public var q: String?
    public var host: String?
    public var lang: String?
    public var after: String?
    public var before: String?
    public var limit: Int?
    public var offset: Int?
}

public struct queryPages: APIRequest {
    public typealias Body = NoBody
    public typealias Response = queryPagesResponse
    public var method: String { "GET" }
    public var parameters: queryPagesParameters
    public var path: String {
        var path = "/v1/pages"
        var query: [String] = []
        if let value = parameters.q { query.append("q=\(value)") }
        if let value = parameters.host { query.append("host=\(value)") }
        if let value = parameters.lang { query.append("lang=\(value)") }
        if let value = parameters.after { query.append("after=\(value)") }
        if let value = parameters.before { query.append("before=\(value)") }
        if let value = parameters.limit { query.append("limit=\(value)") }
        if let value = parameters.offset { query.append("offset=\(value)") }
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: queryPagesParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

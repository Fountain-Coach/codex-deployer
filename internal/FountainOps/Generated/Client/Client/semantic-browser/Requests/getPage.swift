import Foundation

public struct getPageParameters: Codable {
    public let id: String
}

public struct getPage: APIRequest {
    public typealias Body = NoBody
    public typealias Response = PageDoc
    public var method: String { "GET" }
    public var parameters: getPageParameters
    public var path: String {
        var path = "/v1/pages/{id}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{id}", with: String(parameters.id))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: getPageParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

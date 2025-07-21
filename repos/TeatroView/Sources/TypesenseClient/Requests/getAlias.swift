import Foundation

public struct getAliasParameters: Codable {
    public let aliasname: String
}

public struct getAlias: APIRequest {
    public typealias Body = NoBody
    public typealias Response = CollectionAlias
    public var method: String { "GET" }
    public var parameters: getAliasParameters
    public var path: String {
        var path = "/aliases/{aliasName}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{aliasName}", with: String(parameters.aliasname))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: getAliasParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

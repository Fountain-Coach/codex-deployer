import Foundation

public struct upsertAliasParameters: Codable {
    public let aliasname: String
}

public struct upsertAlias: APIRequest {
    public typealias Body = CollectionAliasSchema
    public typealias Response = CollectionAlias
    public var method: String { "PUT" }
    public var parameters: upsertAliasParameters
    public var path: String {
        var path = "/aliases/{aliasName}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{aliasName}", with: String(parameters.aliasname))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: upsertAliasParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

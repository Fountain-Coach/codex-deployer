import Foundation

public struct getCollectionParameters: Codable {
    public let collectionName: String
}

public struct getCollection: APIRequest {
    public typealias Body = NoBody
    public typealias Response = CollectionResponse
    public var method: String { "GET" }
    public var parameters: getCollectionParameters
    public var path: String {
        var path = "/collections/{collectionName}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{collectionName}", with: String(parameters.collectionName))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: getCollectionParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

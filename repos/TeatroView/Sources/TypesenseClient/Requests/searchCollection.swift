import Foundation

public struct searchCollectionParameters: Codable {
    public let collectionname: String
    public let searchparameters: SearchParameters
}

public struct searchCollection: APIRequest {
    public typealias Body = NoBody
    public typealias Response = SearchResult
    public var method: String { "GET" }
    public var parameters: searchCollectionParameters
    public var path: String {
        var path = "/collections/{collectionName}/documents/search"
        let query: [String] = {
            ["searchParameters=\(parameters.searchparameters)"]
        }()
        path = path.replacingOccurrences(of: "{collectionName}", with: String(parameters.collectionname))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: searchCollectionParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

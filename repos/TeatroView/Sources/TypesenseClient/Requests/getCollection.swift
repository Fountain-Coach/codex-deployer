import Foundation

public struct getCollectionParameters: Codable {
    public let collectionName: String
}

public struct getCollection: APIRequest {
    public typealias Body = NoBody
    public typealias Response = CollectionResponse
    public var method: String { "GET" }
    public var parameters: getCollectionParameters
    public var path: String { "/collections/\(parameters.collectionName)" }
    public var body: Body?

    public init(parameters: getCollectionParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

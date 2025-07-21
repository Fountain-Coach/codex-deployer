import Foundation

public struct deleteDocumentsParameters: Codable {
    public let collectionname: String
    public var deletedocumentsparameters: [String: String]?
}

public struct deleteDocuments: APIRequest {
    public typealias Body = NoBody
    public typealias Response = deleteDocumentsResponse
    public var method: String { "DELETE" }
    public var parameters: deleteDocumentsParameters
    public var path: String {
        var path = "/collections/{collectionName}/documents"
        let query: [String] = {
            var items: [String] = []
            if let value = parameters.deletedocumentsparameters {
                items.append("deleteDocumentsParameters=\(value)")
            }
            return items
        }()
        path = path.replacingOccurrences(of: "{collectionName}", with: String(parameters.collectionname))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: deleteDocumentsParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

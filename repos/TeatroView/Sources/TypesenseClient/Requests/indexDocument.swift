import Foundation

public struct indexDocumentParameters: Codable {
    public let collectionname: String
    public var action: IndexAction?
    public var dirtyValues: DirtyValues?
}

public struct indexDocument: APIRequest {
    public typealias Body = indexDocumentRequest
    public typealias Response = Data
    public var method: String { "POST" }
    public var parameters: indexDocumentParameters
    public var path: String {
        var path = "/collections/{collectionName}/documents"
        let query: [String] = {
            var items: [String] = []
            if let value = parameters.action {
                items.append("action=\(value)")
            }
            if let value = parameters.dirtyValues {
                items.append("dirty_values=\(value)")
            }
            return items
        }()
        path = path.replacingOccurrences(of: "{collectionName}", with: String(parameters.collectionname))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: indexDocumentParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

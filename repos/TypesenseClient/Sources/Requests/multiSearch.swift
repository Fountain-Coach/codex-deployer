import Foundation

public struct multiSearchParameters: Codable {
    public let multisearchparameters: MultiSearchParameters
}

public struct multiSearch: APIRequest {
    public typealias Body = MultiSearchSearchesParameter
    public typealias Response = MultiSearchResult
    public var method: String { "POST" }
    public var parameters: multiSearchParameters
    public var path: String {
        var path = "/multi_search"
        let query: [String] = {
            ["multiSearchParameters=\(parameters.multisearchparameters)"]
        }()
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: multiSearchParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

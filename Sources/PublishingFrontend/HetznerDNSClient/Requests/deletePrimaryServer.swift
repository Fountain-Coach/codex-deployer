import Foundation

public struct deletePrimaryServerParameters: Codable {
    public let primaryserverid: String
}

public struct deletePrimaryServer: APIRequest {
    public typealias Body = NoBody
    public typealias Response = Data
    public var method: String { "DELETE" }
    public var parameters: deletePrimaryServerParameters
    public var path: String {
        var path = "/primary_servers/{PrimaryServerID}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{PrimaryServerID}", with: String(parameters.primaryserverid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: deletePrimaryServerParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

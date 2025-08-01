import Foundation

public struct getPrimaryServerParameters: Codable {
    public let primaryserverid: String
}

public struct getPrimaryServer: APIRequest {
    public typealias Body = NoBody
    public typealias Response = PrimaryServerResponse
    public var method: String { "GET" }
    public var parameters: getPrimaryServerParameters
    public var path: String {
        var path = "/primary_servers/{PrimaryServerID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{PrimaryServerID}", with: String(parameters.primaryserverid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: getPrimaryServerParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

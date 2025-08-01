import Foundation

public struct updatePrimaryServerParameters: Codable {
    public let primaryserverid: String
}

public struct updatePrimaryServer: APIRequest {
    public typealias Body = PrimaryServerCreate
    public typealias Response = PrimaryServerResponse
    public var method: String { "PUT" }
    public var parameters: updatePrimaryServerParameters
    public var path: String {
        var path = "/primary_servers/{PrimaryServerID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{PrimaryServerID}", with: String(parameters.primaryserverid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: updatePrimaryServerParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

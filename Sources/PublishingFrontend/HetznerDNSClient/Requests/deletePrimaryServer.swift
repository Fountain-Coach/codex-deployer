import Foundation

/// Parameters for the ``deletePrimaryServer`` request.
public struct deletePrimaryServerParameters: Codable {
    /// Identifier of the primary server to remove.
    public let primaryserverid: String
}

/// Request removing a primary DNS server by identifier.
public struct deletePrimaryServer: APIRequest {
    /// This request carries no body.
    public typealias Body = NoBody
    /// Hetzner's API returns an empty payload.
    public typealias Response = Data
    /// HTTP method for the request.
    public var method: String { "DELETE" }
    /// Path parameters identifying the primary server.
    public var parameters: deletePrimaryServerParameters
    /// API endpoint path interpolating the primary server ID.
    public var path: String {
        var path = "/primary_servers/{PrimaryServerID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{PrimaryServerID}", with: String(parameters.primaryserverid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Optional request body kept for protocol conformance.
    public var body: Body?

    /// Creates a new delete request.
    /// - Parameters:
    ///   - parameters: Values interpolated into the endpoint path.
    ///   - body: Unused placeholder body.
    public init(parameters: deletePrimaryServerParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

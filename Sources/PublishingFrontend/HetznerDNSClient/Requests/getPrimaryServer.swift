import Foundation

/// Parameters used when retrieving a specific primary server.
public struct getPrimaryServerParameters: Codable {
    /// Identifier of the primary server to fetch.
    public let primaryserverid: String
}

/// Request returning details for a primary DNS server.
public struct getPrimaryServer: APIRequest {
    /// Request body is unused for this endpoint.
    public typealias Body = NoBody
    /// Structured response describing the server.
    public typealias Response = PrimaryServerResponse
    /// HTTP method used to fetch the server.
    public var method: String { "GET" }
    /// Path parameters specifying the server identifier.
    public var parameters: getPrimaryServerParameters
    /// API endpoint path rendered with parameters.
    public var path: String {
        var path = "/primary_servers/{PrimaryServerID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{PrimaryServerID}", with: String(parameters.primaryserverid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Body is always `nil` for GET requests.
    public var body: Body?

    /// Creates a request configured with path parameters.
    /// - Parameters:
    ///   - parameters: Identifier for the primary server.
    ///   - body: Optional request body (unused).
    public init(parameters: getPrimaryServerParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation

/// Parameters for ``updatePrimaryServer`` identifying the server to modify.
public struct updatePrimaryServerParameters: Codable {
    /// The identifier of the primary server to update.
    public let primaryserverid: String
}

/// Updates an existing primary DNS server configuration.
///
/// Corresponds to the `PUT /primary_servers/{PrimaryServerID}` endpoint.
public struct updatePrimaryServer: APIRequest {
    /// Body describing the new primary server configuration.
    public typealias Body = PrimaryServerCreate
    /// Response returned after updating the primary server.
    public typealias Response = PrimaryServerResponse
    /// HTTP method used for the request.
    public var method: String { "PUT" }
    /// Identifies which primary server to update.
    public var parameters: updatePrimaryServerParameters
    /// Constructed path for the request.
    public var path: String {
        var path = "/primary_servers/{PrimaryServerID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{PrimaryServerID}", with: String(parameters.primaryserverid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Request body containing the updated server data.
    public var body: Body?

    /// Creates a new request to update a primary server.
    /// - Parameters:
    ///   - parameters: Identifies the target primary server.
    ///   - body: New server settings to apply.
    public init(parameters: updatePrimaryServerParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

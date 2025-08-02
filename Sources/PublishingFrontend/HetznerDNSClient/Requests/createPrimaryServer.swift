import Foundation

/// Request creating a new primary DNS server.
public struct createPrimaryServer: APIRequest {
    /// Payload describing the server to create.
    public typealias Body = PrimaryServerCreate
    /// Hetzner's response contains no structured body.
    public typealias Response = Data
    /// HTTP method used for the request.
    public var method: String { "POST" }
    /// API endpoint path for creating primary servers.
    public var path: String { "/primary_servers" }
    /// Optional request body sent to the API.
    public var body: Body?

    /// Creates a new request optionally carrying a body.
    /// - Parameter body: Attributes describing the primary server.
    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

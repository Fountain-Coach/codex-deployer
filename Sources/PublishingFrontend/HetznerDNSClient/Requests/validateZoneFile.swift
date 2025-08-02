import Foundation

/// Validates a DNS zone file before importing it into Hetzner DNS.
///
/// Corresponds to the `POST /zones/file/validate` endpoint.
public struct validateZoneFile: APIRequest {
    /// The request carries no body payload.
    public typealias Body = NoBody
    /// Response describing validation errors or success.
    public typealias Response = validateZoneFileResponse
    /// HTTP method used by the API.
    public var method: String { "POST" }
    /// Endpoint path for zone file validation.
    public var path: String { "/zones/file/validate" }
    /// Placeholder body maintained for protocol conformance.
    public var body: Body?

    /// Creates a new validation request.
    /// - Parameter body: Unused placeholder body value.
    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

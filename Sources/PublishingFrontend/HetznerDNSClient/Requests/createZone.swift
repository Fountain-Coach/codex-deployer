import Foundation

/// Request to create a new DNS zone.
public struct createZone: APIRequest {
    /// Request payload specifying zone attributes.
    public typealias Body = ZoneCreateRequest
    /// Raw response data returned by the API.
    public typealias Response = Data
    /// HTTP method for the create zone operation.
    public var method: String { "POST" }
    /// Endpoint path for zone creation.
    public var path: String { "/zones" }
    /// Optional request body with zone details.
    public var body: Body?

    /// Creates a new zone creation request.
    /// - Parameter body: Optional zone description to send.
    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

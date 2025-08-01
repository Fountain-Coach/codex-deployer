import Foundation

/// Parameters identifying the zone to remove.
public struct deleteZoneParameters: Codable {
    /// The ID of the zone to delete.
    public let zoneid: String
}

/// Request object for deleting an entire DNS zone.
public struct deleteZone: APIRequest {
    /// The request body is empty.
    public typealias Body = NoBody
    /// The API returns an empty response body.
    public typealias Response = Data
    public var method: String { "DELETE" }
    public var parameters: deleteZoneParameters
    public var path: String {
        var path = "/zones/{ZoneID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    /// Creates a new delete zone request.
    /// - Parameters:
    ///   - parameters: Identifier for the zone to delete.
    ///   - body: Unused placeholder body, kept for protocol conformity.
    public init(parameters: deleteZoneParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

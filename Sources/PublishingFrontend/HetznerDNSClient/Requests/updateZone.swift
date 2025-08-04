import Foundation

/// Parameters for ``updateZone`` identifying which zone to modify.
public struct updateZoneParameters: Codable {
    /// The ID of the zone being updated.
    public let zoneid: String
}

/// Request for updating DNS zone settings.
public struct updateZone: APIRequest {
    /// ``ZoneUpdateRequest`` payload describing changes.
    public typealias Body = ZoneUpdateRequest
    /// Response containing the updated zone representation.
    public typealias Response = ZoneResponse
    /// HTTP method used when updating a DNS zone.
    public var method: String { "PUT" }
    /// Identifier parameters selecting which zone to modify.
    public var parameters: updateZoneParameters
    /// API path with the zone identifier substituted.
    public var path: String {
        var path = "/zones/{ZoneID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Optional request body describing updated zone configuration.
    public var body: Body?

    /// Creates a new zone update request.
    /// - Parameters:
    ///   - parameters: Zone identifier wrapper.
    ///   - body: Data describing the updated zone configuration.
    public init(parameters: updateZoneParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

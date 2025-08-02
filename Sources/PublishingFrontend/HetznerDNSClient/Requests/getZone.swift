import Foundation

/// Parameters for ``getZone`` request.
public struct getZoneParameters: Codable {
    /// Identifier of the zone to fetch.
    public let zoneid: String
}

/// Request retrieving details for a DNS zone.
public struct getZone: APIRequest {
    public typealias Body = NoBody
    public typealias Response = ZoneResponse
    public var method: String { "GET" }
    public var parameters: getZoneParameters
    public var path: String {
        var path = "/zones/{ZoneID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    /// Creates a new ``getZone`` request.
    /// - Parameters:
    ///   - parameters: Zone identifier.
    ///   - body: Always `nil`.
    public init(parameters: getZoneParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

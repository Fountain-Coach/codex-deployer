import Foundation

public struct deleteZoneParameters: Codable {
    public let zoneid: String
}

public struct deleteZone: APIRequest {
    public typealias Body = NoBody
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

    public init(parameters: deleteZoneParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

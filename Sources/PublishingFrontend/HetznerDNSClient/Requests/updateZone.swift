import Foundation

public struct updateZoneParameters: Codable {
    public let zoneid: String
}

public struct updateZone: APIRequest {
    public typealias Body = ZoneUpdateRequest
    public typealias Response = ZoneResponse
    public var method: String { "PUT" }
    public var parameters: updateZoneParameters
    public var path: String {
        var path = "/zones/{ZoneID}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: updateZoneParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

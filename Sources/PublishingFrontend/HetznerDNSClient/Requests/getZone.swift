import Foundation

public struct getZoneParameters: Codable {
    public let zoneid: String
}

public struct getZone: APIRequest {
    public typealias Body = NoBody
    public typealias Response = ZoneResponse
    public var method: String { "GET" }
    public var parameters: getZoneParameters
    public var path: String {
        var path = "/zones/{ZoneID}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: getZoneParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

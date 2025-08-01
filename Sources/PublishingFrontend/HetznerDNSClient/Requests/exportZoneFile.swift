import Foundation

public struct exportZoneFileParameters: Codable {
    public let zoneid: String
}

public struct exportZoneFile: APIRequest {
    public typealias Body = NoBody
    public typealias Response = Data
    public var method: String { "GET" }
    public var parameters: exportZoneFileParameters
    public var path: String {
        var path = "/zones/{ZoneID}/export"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: exportZoneFileParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

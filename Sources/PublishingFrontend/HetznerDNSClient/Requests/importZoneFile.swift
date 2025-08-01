import Foundation

public struct importZoneFileParameters: Codable {
    public let zoneid: String
}

public struct importZoneFile: APIRequest {
    public typealias Body = NoBody
    public typealias Response = Data
    public var method: String { "POST" }
    public var parameters: importZoneFileParameters
    public var path: String {
        var path = "/zones/{ZoneID}/import"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: importZoneFileParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

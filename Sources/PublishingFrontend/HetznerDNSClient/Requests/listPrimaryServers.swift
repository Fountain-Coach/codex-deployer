import Foundation

public struct listPrimaryServersParameters: Codable {
    public var zoneId: String?
}

public struct listPrimaryServers: APIRequest {
    public typealias Body = NoBody
    public typealias Response = PrimaryServersResponse
    public var method: String { "GET" }
    public var parameters: listPrimaryServersParameters
    public var path: String {
        var path = "/primary_servers"
        var query: [String] = []
        if let value = parameters.zoneId { query.append("zone_id=\(value)") }
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: listPrimaryServersParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

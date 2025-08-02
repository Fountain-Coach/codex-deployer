import Foundation

/// Parameters controlling ``listPrimaryServers``.
public struct listPrimaryServersParameters: Codable {
    /// Optional zone identifier to filter servers.
    public var zoneId: String?
}

/// Request listing primary DNS servers for a zone.
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

    /// Creates a new ``listPrimaryServers`` request.
    /// - Parameters:
    ///   - parameters: Zone identifier.
    ///   - body: Always `nil`.
    public init(parameters: listPrimaryServersParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

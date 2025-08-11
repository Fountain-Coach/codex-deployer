import Foundation

public struct deleteRouteParameters: Codable {
    public let routeid: String
}

public struct deleteRoute: APIRequest {
    public typealias Body = NoBody
    public typealias Response = Data
    public var method: String { "DELETE" }
    public var parameters: deleteRouteParameters
    public var path: String {
        var path = "/routes/{routeId}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{routeId}", with: String(parameters.routeid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: deleteRouteParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

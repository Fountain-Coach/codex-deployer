import Foundation

public struct updateRouteParameters: Codable {
    public let routeid: String
}

public struct updateRoute: APIRequest {
    public typealias Body = RouteInfo
    public typealias Response = RouteInfo
    public var method: String { "PUT" }
    public var parameters: updateRouteParameters
    public var path: String {
        var path = "/routes/{routeId}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{routeId}", with: String(parameters.routeid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: updateRouteParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

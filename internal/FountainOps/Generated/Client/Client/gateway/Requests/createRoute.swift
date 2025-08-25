import Foundation

public struct createRoute: APIRequest {
    public typealias Body = RouteInfo
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/routes" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation

public struct listRoutes: APIRequest {
    public typealias Body = NoBody
    public typealias Response = listRoutesResponse
    public var method: String { "GET" }
    public var path: String { "/routes" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

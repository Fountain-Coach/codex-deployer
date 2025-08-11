import Foundation

public struct gatewayHealth: APIRequest {
    public typealias Body = NoBody
    public typealias Response = gatewayHealthResponse
    public var method: String { "GET" }
    public var path: String { "/health" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

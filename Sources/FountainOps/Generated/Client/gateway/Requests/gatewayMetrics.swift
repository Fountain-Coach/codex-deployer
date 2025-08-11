import Foundation

public struct gatewayMetrics: APIRequest {
    public typealias Body = NoBody
    public typealias Response = gatewayMetricsResponse
    public var method: String { "GET" }
    public var path: String { "/metrics" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

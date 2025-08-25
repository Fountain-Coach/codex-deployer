import Foundation

public struct metrics_metrics_get: APIRequest {
    public typealias Body = NoBody
    public typealias Response = metrics_metrics_getResponse
    public var method: String { "GET" }
    public var path: String { "/metrics" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

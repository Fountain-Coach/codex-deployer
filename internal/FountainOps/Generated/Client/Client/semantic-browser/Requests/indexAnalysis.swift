import Foundation

public struct indexAnalysis: APIRequest {
    public typealias Body = IndexRequest
    public typealias Response = IndexResult
    public var method: String { "POST" }
    public var path: String { "/v1/index" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

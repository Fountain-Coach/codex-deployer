import Foundation

public struct addBaseline: APIRequest {
    public typealias Body = BaselineRequest
    public typealias Response = addBaselineResponse
    public var method: String { "POST" }
    public var path: String { "/corpus/baseline" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

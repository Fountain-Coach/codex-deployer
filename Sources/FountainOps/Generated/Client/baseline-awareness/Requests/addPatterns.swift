import Foundation

public struct addPatterns: APIRequest {
    public typealias Body = PatternsRequest
    public typealias Response = addPatternsResponse
    public var method: String { "POST" }
    public var path: String { "/corpus/patterns" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation

public struct analyzeSnapshot: APIRequest {
    public typealias Body = AnalyzeRequest
    public typealias Response = Analysis
    public var method: String { "POST" }
    public var path: String { "/v1/analyze" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

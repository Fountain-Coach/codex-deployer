import Foundation

public struct retrieveAPIStats: APIRequest {
    public typealias Body = NoBody
    public typealias Response = APIStatsResponse
    public var method: String { "GET" }
    public var path: String { "/stats.json" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

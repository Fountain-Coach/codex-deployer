import Foundation

public struct health_check: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/_health" }
    public init() {}
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

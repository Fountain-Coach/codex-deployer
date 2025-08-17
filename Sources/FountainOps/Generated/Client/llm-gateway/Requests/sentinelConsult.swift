import Foundation

public struct sentinelConsult: APIRequest {
    public typealias Body = SecurityCheckRequest
    public typealias Response = SecurityDecision
    public var method: String { "POST" }
    public var path: String { "/sentinel/consult" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

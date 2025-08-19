import Foundation

public struct manifest: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/manifest" }
    public init() {}
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

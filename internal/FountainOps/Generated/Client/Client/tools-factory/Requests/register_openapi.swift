import Foundation

public struct register_openapi: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/tools/register" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

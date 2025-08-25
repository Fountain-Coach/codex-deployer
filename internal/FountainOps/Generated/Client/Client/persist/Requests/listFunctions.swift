import Foundation

public struct listFunctions: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/functions" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

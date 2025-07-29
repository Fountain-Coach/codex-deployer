import Foundation

public struct getFunctionDetails: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/functions/{functionId}" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

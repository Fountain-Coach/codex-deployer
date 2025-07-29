import Foundation

public struct get_function_details: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/functions/{function_id}" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

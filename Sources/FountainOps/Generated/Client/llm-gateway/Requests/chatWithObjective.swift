import Foundation

public struct chatWithObjective: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/chat" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

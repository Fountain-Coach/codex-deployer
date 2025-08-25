import Foundation

public struct planner_reason: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/planner/reason" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

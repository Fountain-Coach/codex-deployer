import Foundation

public struct planner_execute: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/planner/execute" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

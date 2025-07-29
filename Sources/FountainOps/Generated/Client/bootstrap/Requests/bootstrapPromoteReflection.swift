import Foundation

public struct bootstrapPromoteReflection: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/bootstrap/roles/promote" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

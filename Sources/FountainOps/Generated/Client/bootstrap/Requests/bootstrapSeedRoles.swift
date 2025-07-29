import Foundation

public struct bootstrapSeedRoles: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/bootstrap/roles/seed" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

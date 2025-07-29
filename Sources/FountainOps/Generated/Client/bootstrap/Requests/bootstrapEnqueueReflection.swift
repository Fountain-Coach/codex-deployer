import Foundation

public struct bootstrapEnqueueReflection: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/bootstrap/corpus/reflect" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

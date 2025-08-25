import Foundation

public struct addReflection: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/corpora/{corpusId}/reflections" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

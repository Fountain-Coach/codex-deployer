import Foundation

public struct listReflections: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/corpora/{corpusId}/reflections" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

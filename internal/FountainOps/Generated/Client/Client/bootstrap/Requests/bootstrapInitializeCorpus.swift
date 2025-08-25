import Foundation

public struct bootstrapInitializeCorpus: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/bootstrap/corpus/init" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

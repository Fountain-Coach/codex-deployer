import Foundation

public struct addBaseline: APIRequest {
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/corpora/{corpusId}/baselines" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation

public struct listCorpora: APIRequest {
    public typealias Response = Data
    public var method: String { "GET" }
    public var path: String { "/corpora" }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

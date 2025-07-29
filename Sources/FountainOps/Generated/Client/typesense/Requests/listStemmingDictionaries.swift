import Foundation

public struct listStemmingDictionaries: APIRequest {
    public typealias Body = NoBody
    public typealias Response = listStemmingDictionariesResponse
    public var method: String { "GET" }
    public var path: String { "/stemming/dictionaries" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

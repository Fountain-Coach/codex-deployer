import Foundation

public struct addDrift: APIRequest {
    public typealias Body = DriftRequest
    public typealias Response = addDriftResponse
    public var method: String { "POST" }
    public var path: String { "/corpus/drift" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

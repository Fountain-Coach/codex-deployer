import Foundation

public struct addReflection: APIRequest {
    public typealias Body = ReflectionRequest
    public typealias Response = addReflectionResponse
    public var method: String { "POST" }
    public var path: String { "/corpus/reflections" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

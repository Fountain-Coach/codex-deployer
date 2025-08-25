import Foundation

public struct renewCertificate: APIRequest {
    public typealias Body = NoBody
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/certificates/renew" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

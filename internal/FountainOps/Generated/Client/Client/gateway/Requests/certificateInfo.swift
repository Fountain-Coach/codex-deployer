import Foundation

public struct certificateInfo: APIRequest {
    public typealias Body = NoBody
    public typealias Response = CertificateInfo
    public var method: String { "GET" }
    public var path: String { "/certificates" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

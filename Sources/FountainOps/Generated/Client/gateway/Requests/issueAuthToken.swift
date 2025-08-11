import Foundation

public struct issueAuthToken: APIRequest {
    public typealias Body = CredentialRequest
    public typealias Response = TokenResponse
    public var method: String { "POST" }
    public var path: String { "/auth/token" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

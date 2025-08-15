import Foundation

public struct browseAndDissect: APIRequest {
    public typealias Body = BrowseRequest
    public typealias Response = BrowseResponse
    public var method: String { "POST" }
    public var path: String { "/v1/browse" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

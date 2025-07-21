import Foundation

public struct getKeys: APIRequest {
    public typealias Body = NoBody
    public typealias Response = ApiKeysResponse
    public var method: String { "GET" }
    public var path: String { "/keys" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

import Foundation

public struct createKey: APIRequest {
    public typealias Body = ApiKeySchema
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/keys" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

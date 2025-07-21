import Foundation

public struct createCollection: APIRequest {
    public typealias Body = CollectionSchema
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/collections" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

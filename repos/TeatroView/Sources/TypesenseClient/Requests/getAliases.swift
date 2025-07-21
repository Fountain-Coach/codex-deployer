import Foundation

public struct getAliases: APIRequest {
    public typealias Body = NoBody
    public typealias Response = CollectionAliasesResponse
    public var method: String { "GET" }
    public var path: String { "/aliases" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

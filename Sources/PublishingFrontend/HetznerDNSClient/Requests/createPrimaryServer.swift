import Foundation

public struct createPrimaryServer: APIRequest {
    public typealias Body = PrimaryServerCreate
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/primary_servers" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

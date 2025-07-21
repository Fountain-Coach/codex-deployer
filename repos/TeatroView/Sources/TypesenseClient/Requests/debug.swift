import Foundation

public struct debug: APIRequest {
    public typealias Body = NoBody
    public typealias Response = debugResponse
    public var method: String { "GET" }
    public var path: String { "/debug" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

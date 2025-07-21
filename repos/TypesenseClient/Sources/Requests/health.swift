import Foundation

public struct health: APIRequest {
    public typealias Body = NoBody
    public typealias Response = HealthStatus
    public var method: String { "GET" }
    public var path: String { "/health" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

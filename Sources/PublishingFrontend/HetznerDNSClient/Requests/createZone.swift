import Foundation

public struct createZone: APIRequest {
    public typealias Body = ZoneCreateRequest
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/zones" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

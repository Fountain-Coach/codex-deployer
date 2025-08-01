import Foundation

public struct CreateRecord: APIRequest {
    public typealias Body = RecordCreate
    public typealias Response = RecordResponse
    public var method: String { "POST" }
    public var path: String { "/records" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

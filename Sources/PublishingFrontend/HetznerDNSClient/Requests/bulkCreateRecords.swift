import Foundation

public struct bulkCreateRecords: APIRequest {
    public typealias Body = BulkRecordsCreateRequest
    public typealias Response = BulkRecordsCreateResponse
    public var method: String { "POST" }
    public var path: String { "/records/bulk" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

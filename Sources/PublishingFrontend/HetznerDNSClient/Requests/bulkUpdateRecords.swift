import Foundation

public struct bulkUpdateRecords: APIRequest {
    public typealias Body = BulkRecordsUpdateRequest
    public typealias Response = BulkRecordsUpdateResponse
    public var method: String { "PUT" }
    public var path: String { "/records/bulk" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

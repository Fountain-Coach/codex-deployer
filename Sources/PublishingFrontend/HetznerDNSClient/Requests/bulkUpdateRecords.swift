import Foundation

/// Updates multiple DNS records in one API call.
public struct bulkUpdateRecords: APIRequest {
    /// Batch request payload describing record updates.
    public typealias Body = BulkRecordsUpdateRequest
    /// Response summarizing the update results.
    public typealias Response = BulkRecordsUpdateResponse
    /// HTTP method used for the bulk update operation.
    public var method: String { "PUT" }
    /// Endpoint path targeting the bulk record update API.
    public var path: String { "/records/bulk" }
    /// Optional payload describing the records to update.
    public var body: Body?

    /// Creates a new bulk update request.
    /// - Parameter body: Collection of record changes to apply.
    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

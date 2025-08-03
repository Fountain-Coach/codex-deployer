import Foundation

/// Request to create multiple DNS records in a single call.
public struct bulkCreateRecords: APIRequest {
    /// Payload describing the records to create.
    public typealias Body = BulkRecordsCreateRequest
    /// Response returned after creating the records.
    public typealias Response = BulkRecordsCreateResponse
    /// HTTP method used for the request.
    public var method: String { "POST" }
    /// Endpoint path for the bulk creation API.
    public var path: String { "/records/bulk" }
    /// Optional request body containing records to create.
    public var body: Body?

    /// Creates a new bulk record creation request.
    /// - Parameter body: Optional payload describing records to create.
    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

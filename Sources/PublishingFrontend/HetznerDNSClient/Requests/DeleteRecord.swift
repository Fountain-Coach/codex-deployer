import Foundation

/// Identifies the DNS record to remove.
public struct DeleteRecordParameters: Codable {
    /// Unique identifier of the record to delete.
    public let recordid: String
}

/// Request wrapper for deleting a specific DNS record.
public struct DeleteRecord: APIRequest {
    /// Empty body for delete operations.
    public typealias Body = NoBody
    /// API returns no content on success.
    public typealias Response = NoBody
    /// HTTP method used to remove the record.
    public var method: String { "DELETE" }
    /// Parameters identifying which record to delete.
    public var parameters: DeleteRecordParameters
    /// API endpoint path where `{RecordID}` is replaced with ``DeleteRecordParameters.recordid``.
    public var path: String {
        var path = "/records/{RecordID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{RecordID}", with: String(parameters.recordid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Optional request body, always `nil` for deletions.
    public var body: Body?

    /// Creates a new delete record request.
    /// - Parameters:
    ///   - parameters: Wrapper containing the record identifier.
    ///   - body: Unused body parameter, defaults to `nil`.
    public init(parameters: DeleteRecordParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

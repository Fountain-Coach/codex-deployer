import Foundation

/// Parameters for ``UpdateRecord`` specifying the record ID.
public struct UpdateRecordParameters: Codable {
    /// Identifier of the record that should be updated.
    public let recordid: String
}

/// Updates the specified DNS record with new values.
///
/// Corresponds to the `PUT /records/{RecordID}` endpoint.
public struct UpdateRecord: APIRequest {
    /// Request body containing the updated record fields.
    public typealias Body = RecordCreate
    /// Expected response returned by the API.
    public typealias Response = RecordResponse
    /// HTTP method used for the request.
    public var method: String { "PUT" }
    /// Parameters describing which record to update.
    public var parameters: UpdateRecordParameters
    /// API endpoint path with `{RecordID}` replaced by ``UpdateRecordParameters.recordid``.
    public var path: String {
        var path = "/records/{RecordID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{RecordID}", with: String(parameters.recordid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Request body containing updated record data.
    public var body: Body?

    /// Creates a new request.
    /// - Parameters:
    ///   - parameters: Identifies the record to update.
    ///   - body: Record data to send as payload.
    public init(parameters: UpdateRecordParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

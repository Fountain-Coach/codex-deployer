import Foundation

/// Parameters accepted by the ``getRecord`` request.
public struct getRecordParameters: Codable {
    /// Identifier of the DNS record to fetch.
    public let recordid: String
}

/// Retrieves a single DNS record by its identifier.
///
/// This request maps to the `GET /records/{RecordID}` endpoint of
/// Hetzner's DNS API.
public struct getRecord: APIRequest {
    /// Empty request body type.
    public typealias Body = NoBody
    /// Successful response body returned by the API.
    public typealias Response = RecordResponse
    /// HTTP method used when performing the request.
    public var method: String { "GET" }
    /// Parameter container holding the record ID.
    public var parameters: getRecordParameters
    /// Resolved request path including the record ID.
    public var path: String {
        var path = "/records/{RecordID}"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{RecordID}", with: String(parameters.recordid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Optional request body, always `nil` for this operation.
    public var body: Body?

    /// Creates a new request.
    /// - Parameters:
    ///   - parameters: Wrapper containing the record ID.
    ///   - body: Optional body, unused for this request.
    public init(parameters: getRecordParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

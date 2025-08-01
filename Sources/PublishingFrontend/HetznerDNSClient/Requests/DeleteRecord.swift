import Foundation

/// Identifies the DNS record to remove.
public struct DeleteRecordParameters: Codable {
    public let recordid: String
}

/// Request wrapper for deleting a specific DNS record.
public struct DeleteRecord: APIRequest {
    public typealias Body = NoBody
    public typealias Response = NoBody
    public var method: String { "DELETE" }
    public var parameters: DeleteRecordParameters
    public var path: String {
        var path = "/records/{RecordID}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{RecordID}", with: String(parameters.recordid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: DeleteRecordParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

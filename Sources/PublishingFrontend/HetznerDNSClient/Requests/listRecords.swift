import Foundation

/// Parameters for ``listRecords`` defining the zone and pagination.
public struct listRecordsParameters: Codable {
    public var zoneId: String?
    public var page: Int?
    public var perPage: Int?
}

/// Request type listing DNS records for a zone.
public struct listRecords: APIRequest {
    public typealias Body = NoBody
    public typealias Response = RecordsResponse
    public var method: String { "GET" }
    public var parameters: listRecordsParameters
    public var path: String {
        var path = "/records"
        var query: [String] = []
        if let value = parameters.zoneId { query.append("zone_id=\(value)") }
        if let value = parameters.page { query.append("page=\(value)") }
        if let value = parameters.perPage { query.append("per_page=\(value)") }
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    /// Creates a new ``listRecords`` request.
    /// - Parameters:
    ///   - parameters: Zone and paging values.
    ///   - body: Always `nil` for this request.
    public init(parameters: listRecordsParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

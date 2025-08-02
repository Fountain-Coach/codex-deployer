import Foundation

/// Parameters for the ``importZoneFile`` request.
public struct importZoneFileParameters: Codable {
    /// Identifier of the zone where the file will be imported.
    public let zoneid: String
}

/// Request that uploads a complete zone file into the DNS service.
public struct importZoneFile: APIRequest {
    /// The request body is empty.
    public typealias Body = NoBody
    /// The API returns raw data describing the import result.
    public typealias Response = Data
    /// HTTP method used to perform the import.
    public var method: String { "POST" }
    /// Encapsulated zone identifier.
    public var parameters: importZoneFileParameters
    public var path: String {
        var path = "/zones/{ZoneID}/import"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    /// Optional body, unused for this request.
    public var body: Body?

    /// Creates a new import zone file request.
    /// - Parameters:
    ///   - parameters: Zone identifier wrapper.
    ///   - body: Placeholder body, defaults to `nil`.
    public init(parameters: importZoneFileParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

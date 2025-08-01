import Foundation

/// Parameters for the ``exportZoneFile`` request.
public struct exportZoneFileParameters: Codable {
    /// Zone identifier whose records should be exported.
    public let zoneid: String
}

/// Request that downloads the full zone file for backup or migration.
public struct exportZoneFile: APIRequest {
    /// The request body is empty.
    public typealias Body = NoBody
    /// The raw zone file data returned from the API.
    public typealias Response = Data
    public var method: String { "GET" }
    public var parameters: exportZoneFileParameters
    public var path: String {
        var path = "/zones/{ZoneID}/export"
        let query: [String] = []
        path = path.replacingOccurrences(of: "{ZoneID}", with: String(parameters.zoneid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    /// Creates a new export zone file request.
    /// - Parameters:
    ///   - parameters: Zone identifier wrapper.
    ///   - body: Placeholder body, defaults to `nil`.
    public init(parameters: exportZoneFileParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

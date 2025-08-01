import Foundation

/// Parameters for filtering the list zones endpoint.
/// When all fields are `nil`, the API returns every zone.
public struct ListZonesParameters: Codable {
    public var name: String?
    public var searchName: String?
    public var page: Int?
    public var perPage: Int?
}

/// Request for fetching DNS zones from the Hetzner API.
/// Builds a query string based on the provided parameters.
public struct ListZones: APIRequest {
    public typealias Body = NoBody
    public typealias Response = ZonesResponse
    public var method: String { "GET" }
    public var parameters: ListZonesParameters
    public var path: String {
        var path = "/zones"
        var query: [String] = []
        if let value = parameters.name { query.append("name=\(value)") }
        if let value = parameters.searchName { query.append("search_name=\(value)") }
        if let value = parameters.page { query.append("page=\(value)") }
        if let value = parameters.perPage { query.append("per_page=\(value)") }
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: ListZonesParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

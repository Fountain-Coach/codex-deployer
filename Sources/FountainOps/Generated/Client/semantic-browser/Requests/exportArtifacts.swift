import Foundation

public struct exportArtifactsParameters: Codable {
    public let pageid: String
    public let format: String
}

public struct exportArtifacts: APIRequest {
    public typealias Body = NoBody
    public typealias Response = exportArtifactsResponse
    public var method: String { "GET" }
    public var parameters: exportArtifactsParameters
    public var path: String {
        var path = "/v1/export"
        var query: [String] = []
        query.append("pageId=\(parameters.pageid)")
        query.append("format=\(parameters.format)")
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: exportArtifactsParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

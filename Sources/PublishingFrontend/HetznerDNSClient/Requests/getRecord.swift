import Foundation

public struct getRecordParameters: Codable {
    public let recordid: String
}

public struct getRecord: APIRequest {
    public typealias Body = NoBody
    public typealias Response = RecordResponse
    public var method: String { "GET" }
    public var parameters: getRecordParameters
    public var path: String {
        var path = "/records/{RecordID}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{RecordID}", with: String(parameters.recordid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: getRecordParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

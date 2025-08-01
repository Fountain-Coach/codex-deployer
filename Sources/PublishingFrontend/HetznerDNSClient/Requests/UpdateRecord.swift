import Foundation

public struct UpdateRecordParameters: Codable {
    public let recordid: String
}

public struct UpdateRecord: APIRequest {
    public typealias Body = RecordCreate
    public typealias Response = RecordResponse
    public var method: String { "PUT" }
    public var parameters: UpdateRecordParameters
    public var path: String {
        var path = "/records/{RecordID}"
        var query: [String] = []
        path = path.replacingOccurrences(of: "{RecordID}", with: String(parameters.recordid))
        if !query.isEmpty { path += "?" + query.joined(separator: "&") }
        return path
    }
    public var body: Body?

    public init(parameters: UpdateRecordParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

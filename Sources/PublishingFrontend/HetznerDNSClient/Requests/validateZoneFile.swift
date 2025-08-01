import Foundation

public struct validateZoneFile: APIRequest {
    public typealias Body = NoBody
    public typealias Response = validateZoneFileResponse
    public var method: String { "POST" }
    public var path: String { "/zones/file/validate" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

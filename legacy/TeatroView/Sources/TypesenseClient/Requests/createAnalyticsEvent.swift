import Foundation

public struct createAnalyticsEvent: APIRequest {
    public typealias Body = AnalyticsEventCreateSchema
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/analytics/events" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

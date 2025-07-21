import Foundation

public struct retrieveAnalyticsRules: APIRequest {
    public typealias Body = NoBody
    public typealias Response = AnalyticsRulesRetrieveSchema
    public var method: String { "GET" }
    public var path: String { "/analytics/rules" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

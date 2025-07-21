import Foundation

public struct upsertAnalyticsRuleParameters: Codable {
    public let ruleName: String
}

public struct upsertAnalyticsRule: APIRequest {
    public typealias Body = AnalyticsRuleUpsertSchema
    public typealias Response = AnalyticsRuleSchema
    public var method: String { "PUT" }
    public var parameters: upsertAnalyticsRuleParameters
    public var path: String { "/analytics/rules/\(parameters.ruleName)" }
    public var body: Body?

    public init(parameters: upsertAnalyticsRuleParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}

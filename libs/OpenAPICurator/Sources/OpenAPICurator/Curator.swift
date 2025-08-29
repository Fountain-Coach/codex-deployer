import Foundation

public struct Spec {
    public let operations: [String]
    public init(operations: [String]) {
        self.operations = operations
    }
}

public struct OpenAPI {
    public var operations: [String]
    public init(operations: [String]) {
        self.operations = operations
    }
}

public struct Rules {
    public let renames: [String: String]
    public init(renames: [String: String] = [:]) {
        self.renames = renames
    }
}

public struct CuratorReport {
    public let appliedRules: [String]
    public let collisions: [String]
    public init(appliedRules: [String], collisions: [String]) {
        self.appliedRules = appliedRules
        self.collisions = collisions
    }
}

public func curate(specs: [Spec], rules: Rules) -> (spec: OpenAPI, report: CuratorReport) {
    let parsed = Parser.parse(specs)
    let normalized = Resolver.normalize(parsed)
    let (ruled, applied) = RulesEngine.apply(rules, to: normalized)
    let (deduped, collisions) = CollisionResolver.resolve(ruled)
    let report = ReportBuilder.build(appliedRules: applied, collisions: collisions)
    return (deduped, report)
}

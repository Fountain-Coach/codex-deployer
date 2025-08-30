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
    public let allowlist: [String]
    public let denylist: [String]
    public init(renames: [String: String] = [:], allowlist: [String] = [], denylist: [String] = []) {
        self.renames = renames
        self.allowlist = allowlist
        self.denylist = denylist
    }
}

public struct CuratorReport {
    public let appliedRules: [String]
    public let collisions: [String]
    public let diff: [String]
    public init(appliedRules: [String], collisions: [String], diff: [String]) {
        self.appliedRules = appliedRules
        self.collisions = collisions
        self.diff = diff
    }
}

public func curate(specs: [Spec], rules: Rules) -> (spec: OpenAPI, report: CuratorReport) {
    let parsed = Parser.parse(specs)
    let normalized = Resolver.normalize(parsed)
    let (ruled, applied) = RulesEngine.apply(rules, to: normalized)
    let diff = normalized.operations.filter { !ruled.operations.contains($0) }
    let (deduped, collisions) = CollisionResolver.resolve(ruled)
    let report = ReportBuilder.build(appliedRules: applied, collisions: collisions, diff: diff)
    return (deduped, report)
}

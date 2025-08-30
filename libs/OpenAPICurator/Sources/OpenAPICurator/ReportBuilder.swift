import Foundation

enum ReportBuilder {
    static func build(appliedRules: [String], collisions: [String], diff: [String]) -> CuratorReport {
        CuratorReport(appliedRules: appliedRules, collisions: collisions, diff: diff)
    }
}

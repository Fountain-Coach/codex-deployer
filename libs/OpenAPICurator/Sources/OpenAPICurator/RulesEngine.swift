import Foundation

enum RulesEngine {
    static func apply(_ rules: Rules, to api: OpenAPI) -> (OpenAPI, [String]) {
        var operations = api.operations
        var applied: [String] = []
        for (index, op) in operations.enumerated() {
            if let newName = rules.renames[op] {
                operations[index] = newName
                applied.append("\(op)->\(newName)")
            }
        }
        if !rules.allowlist.isEmpty {
            let allowed = Set(rules.allowlist)
            operations = operations.filter { allowed.contains($0) }
        }
        if !rules.denylist.isEmpty {
            let denied = Set(rules.denylist)
            let removed = operations.filter { denied.contains($0) }
            applied.append(contentsOf: removed.map { "deny:\($0)" })
            operations = operations.filter { !denied.contains($0) }
        }
        return (OpenAPI(operations: operations), applied)
    }
}

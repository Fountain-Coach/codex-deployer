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
        return (OpenAPI(operations: operations), applied)
    }
}

import Foundation

enum Parser {
    static func parse(_ specs: [Spec]) -> OpenAPI {
        let ops = specs.flatMap { $0.operations }
        return OpenAPI(operations: ops)
    }
}

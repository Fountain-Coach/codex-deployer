import Foundation
import ServiceShared

/// Implements the Tools Factory persistence logic backed by ``TypesenseClient``.
public struct Handlers {
    let typesense: TypesenseClient

    public init(typesense: TypesenseClient = .shared) {
        self.typesense = typesense
    }

    /// Registers one or more functions provided as JSON array of ``Function`` models.
    /// In a real deployment this would parse an OpenAPI document.
    public func registerOpenapi(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let functions = try? JSONDecoder().decode([Function].self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        for fn in functions { await typesense.addFunction(fn) }
        return HTTPResponse()
    }

    /// Returns all stored function definitions.
    public func listTools(_ request: HTTPRequest) async throws -> HTTPResponse {
        let items = await typesense.listFunctions()
        let data = try JSONEncoder().encode(items)
        return HTTPResponse(body: data)
    }
}

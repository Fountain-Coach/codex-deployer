import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ServiceShared
import Parser

/// Dispatches registered functions by looking them up from the shared
/// TypesenseClient and performing a simple URLSession call.
struct FunctionDispatcher {
    enum DispatchError: Error { case notFound, invalidParams, server(Int) }

    func invoke(functionId: String, payload: Data) async throws -> Data {
        guard let fn = await TypesenseClient.shared.functionDetails(id: functionId) else {
            throw DispatchError.notFound
        }
        if let schemaString = fn.parametersSchema,
           let schemaData = schemaString.data(using: .utf8),
           let schema = try? JSONDecoder().decode(OpenAPISpec.Schema.self, from: schemaData) {
            guard let json = try? JSONSerialization.jsonObject(with: payload) as? [String: Any] else {
                throw DispatchError.invalidParams
            }
            if let props = schema.properties {
                for key in props.keys where json[key] == nil {
                    throw DispatchError.invalidParams
                }
            }
        }
        guard let url = URL(string: fn.httpPath) else {
            throw DispatchError.notFound
        }
        var req = URLRequest(url: url)
        req.httpMethod = fn.httpMethod
        req.httpBody = payload
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, http.statusCode >= 400 {
            throw DispatchError.server(http.statusCode)
        }
        return data
    }
}

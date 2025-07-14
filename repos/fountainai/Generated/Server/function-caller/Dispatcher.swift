import Foundation
import FoundationNetworking
import ServiceShared

/// Dispatches registered functions by looking them up from the shared
/// TypesenseClient and performing a simple URLSession call.
struct FunctionDispatcher {
    enum DispatchError: Error { case notFound, server(Int) }

    func invoke(functionId: String, payload: Data) async throws -> Data {
        guard let fn = await TypesenseClient.shared.functionDetails(id: functionId) else {
            throw DispatchError.notFound
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

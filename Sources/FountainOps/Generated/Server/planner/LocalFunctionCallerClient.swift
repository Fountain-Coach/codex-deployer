import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ServiceShared

/// Client for delegating executions to the Function Caller service. When
/// `FUNCTION_CALLER_URL` is unset it falls back to the local dispatcher used
/// during tests. See `docs/environment_variables.md`.
struct LocalFunctionCallerClient {
    enum DispatchError: Error { case notFound }

    private let baseURL: URL?

    init() {
        if let urlString = ProcessInfo.processInfo.environment["FUNCTION_CALLER_URL"],
           let url = URL(string: urlString) {
            self.baseURL = url
        } else {
            self.baseURL = nil
        }
    }

    func invoke(functionId: String, payload: Data) async throws -> Data {
        if let baseURL {
            var req = URLRequest(url: baseURL.appendingPathComponent("functions/\(functionId)/invoke"))
            req.httpMethod = "POST"
            req.httpBody = payload
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = ProcessInfo.processInfo.environment["FUNCTION_CALLER_AUTH_TOKEN"] {
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, _) = try await URLSession.shared.data(for: req)
            return data
        }

        // Fallback to direct invocation via TypesenseClient
        guard let fn = await TypesenseClient.shared.functionDetails(id: functionId),
              let url = URL(string: fn.httpPath) else {
            throw DispatchError.notFound
        }
        var req = URLRequest(url: url)
        req.httpMethod = fn.httpMethod
        req.httpBody = payload
        let (data, _) = try await URLSession.shared.data(for: req)
        return data
    }
}


© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

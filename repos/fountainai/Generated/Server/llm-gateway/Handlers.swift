import Foundation
import FoundationNetworking
import ServiceShared

public struct Handlers {
    public init() {}
    public func chatwithobjective(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return HTTPResponse(status: 500)
        }
        let base = ProcessInfo.processInfo.environment["OPENAI_API_BASE"] ?? "https://api.openai.com/v1/chat/completions"
        var urlRequest = URLRequest(url: URL(string: base)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return HTTPResponse(body: data)
    }
    public func metricsMetricsGet(_ request: HTTPRequest) async throws -> HTTPResponse {
        let text = await PrometheusAdapter.shared.exposition()
        return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data(text.utf8))
    }
}

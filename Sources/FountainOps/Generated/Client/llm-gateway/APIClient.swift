import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Placeholder client for llm-gateway (generated code stub)
public protocol HTTPSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {}

public struct APIClient {
    public let baseURL: URL
    let session: HTTPSession
    public init(baseURL: URL, session: HTTPSession) {
        self.baseURL = baseURL
        self.session = session
    }
    public init(baseURL: URL) {
        self.init(baseURL: baseURL, session: URLSession.shared)
    }

    public func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        var url = baseURL
        url.append(path: request.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, _) = try await session.data(for: urlRequest)
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol HTTPSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request, delegate: nil)
    }
}

public struct APIClient {
    let baseURL: URL
    let session: HTTPSession

    public init(baseURL: URL, session: HTTPSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        urlRequest.httpMethod = request.method
        let (data, _) = try await session.data(for: urlRequest)
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

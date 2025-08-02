import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Abstraction over ``URLSession`` for easier testing.
public protocol HTTPSession {
    /// Performs the given request and returns the server response.
    /// - Parameter request: Request to execute.
    /// - Returns: The response data and URL response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {
    /// Conformance allowing ``APIClient`` to depend on ``HTTPSession``.
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request, delegate: nil)
    }
}

/// Minimal HTTP client for executing ``APIRequest`` values.
public struct APIClient {
    /// Root endpoint used for all requests.
    let baseURL: URL
    /// Transport layer performing network calls.
    let session: HTTPSession
    /// Headers automatically attached to every request.
    let defaultHeaders: [String: String]

    /// Creates a new client with optional session and headers.
    /// - Parameters:
    ///   - baseURL: Base API endpoint.
    ///   - session: Underlying HTTP session implementation.
    ///   - defaultHeaders: Headers applied to every request.
    public init(baseURL: URL, session: HTTPSession = URLSession.shared, defaultHeaders: [String: String] = [:]) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
    }

    /// Executes an ``APIRequest`` and decodes the server response.
    /// - Parameter request: The request to perform.
    /// - Returns: The decoded response value for ``R.Response``.
    public func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        urlRequest.httpMethod = request.method
        for (header, value) in defaultHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: header)
        }
        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, _) = try await session.data(for: urlRequest)
        if R.Response.self == Data.self {
            return data as! R.Response
        }
        if R.Response.self == NoBody.self {
            return NoBody() as! R.Response
        }
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}

public extension APIClient {
    /// Convenience initializer using a bearer token for authorization.
    /// - Parameters:
    ///   - baseURL: Base API endpoint.
    ///   - bearerToken: Token inserted as the `Authorization` header.
    ///   - session: Optional custom session.
    init(baseURL: URL, bearerToken: String, session: HTTPSession = URLSession.shared) {
        self.init(baseURL: baseURL, session: session, defaultHeaders: ["Authorization": "Bearer \(bearerToken)"])
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

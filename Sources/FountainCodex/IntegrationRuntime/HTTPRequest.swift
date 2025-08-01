import Foundation

public struct NoBody: Codable {}

/// Represents an HTTP request flowing through ``HTTPKernel`` powered servers.
/// Stores the HTTP method, path, headers and optional body data.
public struct HTTPRequest: Sendable {
    public let method: String
    public let path: String
    public var headers: [String: String]
    public var body: Data

    /// Creates a new request instance.
    /// - Parameters:
    ///   - method: HTTP verb such as `GET` or `POST`.
    ///   - path: Requested resource path.
    ///   - headers: HTTP headers to include.
    ///   - body: Optional payload data.
    public init(method: String, path: String, headers: [String: String] = [:], body: Data = Data()) {
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

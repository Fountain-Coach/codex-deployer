import Foundation

public struct HTTPRequest {
    public let method: String
    public let path: String
    public var headers: [String: String]
    public var body: Data
    public init(method: String, path: String, headers: [String: String] = [:], body: Data = Data()) {
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
    }
}

public struct HTTPResponse {
    public var status: Int
    public var headers: [String: String]
    public var body: Data
    public init(status: Int = 200, headers: [String: String] = [:], body: Data = Data()) {
        self.status = status
        self.headers = headers
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

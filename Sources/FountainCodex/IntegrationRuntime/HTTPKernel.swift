import Foundation

public struct HTTPKernel: @unchecked Sendable {
    let router: (HTTPRequest) async throws -> HTTPResponse

    public init(route: @escaping (HTTPRequest) async throws -> HTTPResponse) {
        self.router = route
    }

    public func handle(_ request: HTTPRequest) async throws -> HTTPResponse {
        try await router(request)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

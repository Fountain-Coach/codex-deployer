import Foundation
import FountainCodex

/// Minimal router for LLM gateway endpoints.
public struct Router {
    public var handlers: Handlers
    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    /// Routes requests to the appropriate handler.
    /// - Parameter request: Incoming HTTP request.
    /// - Returns: A response if a matching route is found, otherwise `nil`.
    public func route(_ request: HTTPRequest) async throws -> HTTPResponse? {
        switch (request.method, request.path.split(separator: "/", omittingEmptySubsequences: true)) {
        case ("POST", ["sentinel", "consult"]):
            if let body = try? JSONDecoder().decode(SecurityCheckRequest.self, from: request.body) {
                return try await handlers.sentinelConsult(request, body: body)
            }
            return HTTPResponse(status: 400)
        case ("GET", let parts) where parts.count == 3 && parts[0] == "chat" && parts[2] == "cot":
            return try await handlers.chatCoT(request, chatID: String(parts[1]))
        default:
            return nil
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

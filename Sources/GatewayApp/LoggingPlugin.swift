import Foundation
import FountainCodex

/// Plugin that prints incoming requests and outgoing responses to stdout.
public struct LoggingPlugin: GatewayPlugin {
    /// Creates a new logging plugin instance.
    public init() {}

    /// Logs the incoming request before routing.
    /// - Parameter request: The request about to be routed.
    /// - Returns: The unmodified request for further processing.
    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        print("-> \(request.method) \(request.path)")
        return request
    }

    /// Logs the response returned by the router.
    /// - Parameters:
    ///   - response: The generated response.
    ///   - request: The original request that produced the response.
    /// - Returns: The response passed through unchanged.
    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        print("<- \(response.status) for \(request.path)")
        return response
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

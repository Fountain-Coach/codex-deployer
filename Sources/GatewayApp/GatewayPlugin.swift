import Foundation
import FountainCodex

/// Protocol describing middleware hooks for the gateway server.
public protocol GatewayPlugin: Sendable {
    /// Allows mutation or inspection of a request before routing.
    func prepare(_ request: HTTPRequest) async throws -> HTTPRequest
    /// Allows mutation or inspection of the response before it is returned.
    func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse
}

public extension GatewayPlugin {
    /// Default no-op implementation for request preparation.
    func prepare(_ request: HTTPRequest) async throws -> HTTPRequest { request }
    /// Default no-op implementation for response processing.
    func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse { response }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

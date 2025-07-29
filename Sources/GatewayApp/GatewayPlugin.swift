import Foundation
import FountainCodex

public protocol GatewayPlugin: Sendable {
    func prepare(_ request: HTTPRequest) async throws -> HTTPRequest
    func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse
}

public extension GatewayPlugin {
    func prepare(_ request: HTTPRequest) async throws -> HTTPRequest { request }
    func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse { response }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

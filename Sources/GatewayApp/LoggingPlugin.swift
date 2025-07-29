import Foundation
import FountainCodex

public struct LoggingPlugin: GatewayPlugin {
    public init() {}
    public func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
        print("-> \(request.method) \(request.path)")
        return request
    }

    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        print("<- \(response.status) for \(request.path)")
        return response
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

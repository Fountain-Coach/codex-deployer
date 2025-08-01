import Foundation
import FountainCodex

/// Serves static files from disk when requests are not handled elsewhere.
public struct PublishingFrontendPlugin: GatewayPlugin {
    let rootPath: String

    /// Creates a new plugin pointing at the given directory.
    public init(rootPath: String = "./Public") {
        self.rootPath = rootPath
    }

    /// Attempts to serve a file for GET requests that resulted in `404`.
    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        guard request.method == "GET" else { return response }
        let path = rootPath + (request.path == "/" ? "/index.html" : request.path)
        if let data = FileManager.default.contents(atPath: path) {
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/html"], body: data)
        }
        return response
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

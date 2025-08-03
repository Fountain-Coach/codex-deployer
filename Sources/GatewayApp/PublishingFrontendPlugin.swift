import Foundation
import FountainCodex

/// Serves static files from disk when requests are not handled elsewhere.
public struct PublishingFrontendPlugin: GatewayPlugin {
    /// Directory on disk containing files to be served.
    let rootPath: String

    /// Creates a new plugin pointing at the given directory.
    public init(rootPath: String = "./Public") {
        self.rootPath = rootPath
    }

    /// Attempts to serve a static file for GET requests that resulted in `404`.
    /// - Parameters:
    ///   - response: Upstream response, typically `404` from the router.
    ///   - request: Incoming HTTP request to resolve.
    /// - Returns: Either the original response or a `200` with file contents. When a file is served the `Content-Type` header is set to `text/html`.
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

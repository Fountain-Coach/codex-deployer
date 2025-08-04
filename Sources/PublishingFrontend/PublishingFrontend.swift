import Foundation
import NIO
import NIOHTTP1
import FountainCodex
import Yams

/// Configuration for the ``PublishingFrontend`` server.
public struct PublishingConfig: Codable {
    /// TCP port the server listens on.
    public var port: Int
    /// Directory containing static files served by the frontend.
    public var rootPath: String

    /// Creates a new configuration with optional port and root path.
    /// - Parameters:
    ///   - port: Port to bind the HTTP server to.
    ///   - rootPath: Directory containing static files to serve.
    public init(port: Int = 8085, rootPath: String = "./Public") {
        self.port = port
        self.rootPath = rootPath
    }
}

/// Lightweight HTTP server for serving generated documentation.
public final class PublishingFrontend {
    /// Underlying HTTP server handling requests.
    private let server: NIOHTTPServer
    /// Event loop group driving asynchronous operations.
    private let group: EventLoopGroup
    /// Runtime configuration specifying port and root path.
    private let config: PublishingConfig

    /// Creates a new server instance with the given configuration.
    /// - Parameter config: Runtime configuration options.
    public init(config: PublishingConfig) {
        self.config = config
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let kernel = HTTPKernel { [config] req in
            guard req.method == "GET" else { return HTTPResponse(status: 405) }
            let path = config.rootPath + (req.path == "/" ? "/index.html" : req.path)
            if let data = FileManager.default.contents(atPath: path) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/html"], body: data)
            }
            return HTTPResponse(status: 404)
        }
        self.server = NIOHTTPServer(kernel: kernel, group: group)
    }

    @MainActor
    /// Starts the HTTP server on the configured port.
    public func start() async throws {
        _ = try await server.start(port: config.port)
    }

    @MainActor
    /// Stops the HTTP server and releases all resources.
    public func stop() async throws {
        try await server.stop()
    }
}

/// Loads the publishing configuration from `Configuration/publishing.yml`.
/// Missing `port` or `rootPath` keys fall back to the defaults `8085` and `./Public`.
/// - Throws: If the file is missing, contains invalid YAML, or fails decoding into ``PublishingConfig``.
/// - Returns: Parsed ``PublishingConfig`` instance.
public func loadPublishingConfig() throws -> PublishingConfig {
    let url = URL(fileURLWithPath: "Configuration/publishing.yml")
    let string = try String(contentsOf: url, encoding: .utf8)
    let yaml = try Yams.load(yaml: string) as? [String: Any] ?? [:]
    let defaults: [String: Any] = ["port": 8085, "rootPath": "./Public"]
    let merged = defaults.merging(yaml) { _, new in new }
    let data = try JSONSerialization.data(withJSONObject: merged)
    return try JSONDecoder().decode(PublishingConfig.self, from: data)
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

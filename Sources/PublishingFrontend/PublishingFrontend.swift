import Foundation
import NIO
import NIOHTTP1
import FountainCodex
import Yams

public struct PublishingConfig: Codable {
    public var port: Int
    public var rootPath: String

    public init(port: Int = 8085, rootPath: String = "./Public") {
        self.port = port
        self.rootPath = rootPath
    }
}

public final class PublishingFrontend {
    private let server: NIOHTTPServer
    private let group: EventLoopGroup
    private let config: PublishingConfig

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
    public func start() async throws {
        _ = try await server.start(port: config.port)
    }

    @MainActor
    public func stop() async throws {
        try await server.stop()
    }
}

public func loadPublishingConfig() throws -> PublishingConfig {
    let url = URL(fileURLWithPath: "Configuration/publishing.yml")
    let string = try String(contentsOf: url)
    let yaml = try Yams.load(yaml: string) as? [String: Any] ?? [:]
    let data = try JSONSerialization.data(withJSONObject: yaml)
    return try JSONDecoder().decode(PublishingConfig.self, from: data)
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

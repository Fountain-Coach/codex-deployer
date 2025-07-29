import Foundation
import NIO
import NIOHTTP1
import FountainCodex

@MainActor
public final class GatewayServer {
    private let server: NIOHTTPServer
    private let manager: CertificateManager
    private let group: EventLoopGroup

    public init(manager: CertificateManager = CertificateManager()) {
        self.manager = manager
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let kernel = HTTPKernel { req in
            switch (req.method, req.path) {
            case ("GET", "/health"):
                let json = try JSONEncoder().encode(["status": "ok"])
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            case ("GET", "/metrics"):
                let metrics: [String: [String]] = ["metrics": []]
                let json = try JSONEncoder().encode(metrics)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            default:
                return HTTPResponse(status: 404)
            }
        }
        self.server = NIOHTTPServer(kernel: kernel, group: group)
    }

    public func start(port: Int = 8080) async throws {
        manager.start()
        _ = try await server.start(port: port)
    }

    public func stop() async throws {
        manager.stop()
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import Foundation
import NIO
import NIOHTTP1
import FountainCodex

/// HTTP gateway server that composes plugins for request handling.
/// Provides built-in `/health` and `/metrics` endpoints used for monitoring.
@MainActor
public final class GatewayServer {
    private let server: NIOHTTPServer
    private let manager: CertificateManager
    private let group: EventLoopGroup
    private let plugins: [GatewayPlugin]

    /// Creates a new gateway server instance.
    /// - Parameters:
    ///   - manager: Certificate renewal manager.
    ///   - plugins: Plugins applied before and after routing.
    public init(manager: CertificateManager = CertificateManager(),
                plugins: [GatewayPlugin] = []) {
        self.manager = manager
        self.plugins = plugins
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let kernel = HTTPKernel { [plugins] req in
            var request = req
            for plugin in plugins {
                request = try await plugin.prepare(request)
            }
            var response: HTTPResponse
            switch (request.method, request.path) {
            case ("GET", "/health"):
                let json = try JSONEncoder().encode(["status": "ok"])
                response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            case ("GET", "/metrics"):
                let metrics: [String: [String]] = ["metrics": []]
                let json = try JSONEncoder().encode(metrics)
                response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            default:
                response = HTTPResponse(status: 404)
            }
            for plugin in plugins.reversed() {
                response = try await plugin.respond(response, for: request)
            }
            return response
        }
        self.server = NIOHTTPServer(kernel: kernel, group: group)
    }

    /// Starts the gateway on the given port.
    /// - Parameter port: TCP port to bind.
    public func start(port: Int = 8080) async throws {
        manager.start()
        _ = try await server.start(port: port)
    }

    /// Stops the server and terminates certificate renewal.
    public func stop() async throws {
        manager.stop()
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

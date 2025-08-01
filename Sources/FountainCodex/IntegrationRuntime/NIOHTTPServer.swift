@preconcurrency import NIO
@preconcurrency import NIOHTTP1
import Foundation

/// Lightweight SwiftNIO based HTTP server used by FountainAI services.
public final class NIOHTTPServer: @unchecked Sendable {
    let kernel: HTTPKernel
    let group: EventLoopGroup
    var channel: Channel?

    public init(kernel: HTTPKernel, group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)) {
        self.kernel = kernel
        self.group = group
    }

    /// Starts the HTTP server.
    /// - Parameter port: Port to bind the server on.
    /// - Returns: The actual bound port.
    @discardableResult
    public func start(port: Int) async throws -> Int {
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(HTTPHandler(kernel: self.kernel))
                }
            }
        self.channel = try await bootstrap.bind(host: "127.0.0.1", port: port).get()
        return self.channel?.localAddress?.port ?? port
    }

    /// Stops the server and releases allocated resources.
    public func stop() async throws {
        try await channel?.close().get()
        try await group.shutdownGracefully()
    }

    /// Internal NIO channel handler translating NIO events into ``HTTPRequest``s.
    final class HTTPHandler: ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart
        typealias OutboundOut = HTTPServerResponsePart

        let kernel: HTTPKernel
        var head: HTTPRequestHead?
        var body: ByteBuffer?

        init(kernel: HTTPKernel) {
            self.kernel = kernel
        }

        /// Handles inbound HTTP request parts and dispatches them through the ``HTTPKernel``.
        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            switch unwrapInboundIn(data) {
            case .head(let h):
                head = h
                body = context.channel.allocator.buffer(capacity: 0)
            case .body(var part):
                body?.writeBuffer(&part)
            case .end:
                guard let head else { return }
                let req = HTTPRequest(
                    method: head.method.rawValue,
                    path: head.uri,
                    headers: Dictionary(uniqueKeysWithValues: head.headers.map { ($0.name, $0.value) }),
                    body: Data(body?.readableBytesView ?? [])
                )
                Task {
                    let resp = try await self.kernel.handle(req)
                    context.eventLoop.execute {
                        var headers = HTTPHeaders()
                        for (k, v) in resp.headers { headers.add(name: k, value: v) }
                        var responseHead = HTTPResponseHead(version: head.version, status: .init(statusCode: resp.status))
                        responseHead.headers = headers
                        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
                        let buffer = context.channel.allocator.buffer(bytes: resp.body)
                        context.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
                        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                    }
                }
                self.head = nil
                self.body = nil
            }
        }
    }
}

extension NIOHTTPServer.HTTPHandler: @unchecked Sendable {}

extension ChannelHandlerContext: @unchecked @retroactive Sendable {}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

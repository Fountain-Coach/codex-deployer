import XCTest
import Foundation
import NIOCore
import NIOPosix
@testable import FountainCodex

final class DNSServerTests: XCTestCase {
    static func makeQuery(name: String) -> ByteBuffer {
        var buf = ByteBufferAllocator().buffer(capacity: 512)
        buf.writeInteger(UInt16(0x1234), as: UInt16.self)
        buf.writeInteger(UInt16(0), as: UInt16.self)
        buf.writeInteger(UInt16(1), as: UInt16.self)
        buf.writeInteger(UInt16(0), as: UInt16.self)
        buf.writeInteger(UInt16(0), as: UInt16.self)
        buf.writeInteger(UInt16(0), as: UInt16.self)
        for label in name.split(separator: ".") {
            let bytes = Array(label.utf8)
            buf.writeInteger(UInt8(bytes.count), as: UInt8.self)
            buf.writeBytes(bytes)
        }
        buf.writeInteger(UInt8(0), as: UInt8.self)
        buf.writeInteger(UInt16(1), as: UInt16.self)
        buf.writeInteger(UInt16(1), as: UInt16.self)
        return buf
    }

    static func extractIPv4(_ buf: ByteBuffer) -> String? {
        guard buf.readableBytes >= 4 else { return nil }
        let start = buf.readerIndex + buf.readableBytes - 4
        guard let b1: UInt8 = buf.getInteger(at: start),
              let b2: UInt8 = buf.getInteger(at: start + 1),
              let b3: UInt8 = buf.getInteger(at: start + 2),
              let b4: UInt8 = buf.getInteger(at: start + 3) else { return nil }
        return "\(b1).\(b2).\(b3).\(b4)"
    }

    func testServerRespondsToUDPQueries() async throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let manager = try ZoneManager(fileURL: tmp, enableGitCommits: false)
        let zone = try await manager.createZone(name: "example.com")
        let rec = try await manager.createRecord(zoneId: zone.id, name: "", type: "A", value: "1.2.3.4")
        let server = await DNSServer(zoneManager: manager)
        let port = try await server.start(udpPort: 0)

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        var query = Self.makeQuery(name: "example.com")
        let promise = group.next().makePromise(of: ByteBuffer.self)
        var client = try await DatagramBootstrap(group: group)
            .channelInitializer { channel in
                channel.pipeline.addHandler(ResponseHandler(promise: promise))
            }
            .bind(host: "127.0.0.1", port: 0).get()
        let envelope = try AddressedEnvelope(remoteAddress: SocketAddress(ipAddress: "127.0.0.1", port: port), data: query)
        try await client.writeAndFlush(envelope).get()
        var response = try await promise.futureResult.get()
        XCTAssertEqual(Self.extractIPv4(response), "1.2.3.4")

        // update record and ensure server reflects change
        _ = try await manager.updateRecord(zoneId: zone.id, recordId: rec!.id, name: "", type: "A", value: "5.6.7.8")
        try await Task.sleep(nanoseconds: 200_000_000)
        try await client.close().get()
        let promise2 = group.next().makePromise(of: ByteBuffer.self)
        client = try await DatagramBootstrap(group: group)
            .channelInitializer { channel in
                channel.pipeline.addHandler(ResponseHandler(promise: promise2))
            }
            .bind(host: "127.0.0.1", port: 0).get()
        query = Self.makeQuery(name: "example.com")
        let env2 = try AddressedEnvelope(remoteAddress: SocketAddress(ipAddress: "127.0.0.1", port: port), data: query)
        try await client.writeAndFlush(env2).get()
        response = try await promise2.futureResult.get()
        XCTAssertEqual(Self.extractIPv4(response), "5.6.7.8")

        try await client.close().get()
        try await server.stop()
        try await group.shutdownGracefully()
    }

    final class ResponseHandler: ChannelInboundHandler, @unchecked Sendable {
        typealias InboundIn = AddressedEnvelope<ByteBuffer>
        let promise: EventLoopPromise<ByteBuffer>
        init(promise: EventLoopPromise<ByteBuffer>) { self.promise = promise }
        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let env = unwrapInboundIn(data)
            promise.succeed(env.data)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

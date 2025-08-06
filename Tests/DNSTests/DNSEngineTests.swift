import XCTest
import NIOCore
import NIOEmbedded
@testable import FountainCodex

final class DNSEngineTests: XCTestCase {
    func makeQuery(name: String) -> ByteBuffer {
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

    func testRespondsWithARecordFromCache() {
        var query = makeQuery(name: "example.com")
        let engine = DNSEngine(zoneCache: ["example.com": "1.2.3.4"])
        guard var response = engine.handleQuery(buffer: &query) else {
            XCTFail("Expected response")
            return
        }
        response.moveReaderIndex(forwardBy: response.readableBytes - 4)
        let ip1 = response.readInteger(as: UInt8.self)!
        let ip2 = response.readInteger(as: UInt8.self)!
        let ip3 = response.readInteger(as: UInt8.self)!
        let ip4 = response.readInteger(as: UInt8.self)!
        XCTAssertEqual([ip1, ip2, ip3, ip4], [1, 2, 3, 4])
    }

    func testUnknownRecordReturnsNil() {
        var query = makeQuery(name: "unknown.com")
        let engine = DNSEngine(zoneCache: ["example.com": "1.2.3.4"])
        XCTAssertNil(engine.handleQuery(buffer: &query))
    }

    func testHandlerResolvesViaEmbeddedChannel() throws {
        let engine = DNSEngine(zoneCache: ["example.com": "1.2.3.4"])
        let channel = EmbeddedChannel(handler: DNSHandler(engine: engine))
        let query = makeQuery(name: "example.com")
        try channel.writeInbound(query)
        let response: ByteBuffer? = try channel.readOutbound()
        XCTAssertNotNil(response)
    }

    func testMetricsRecorded() async throws {
        await DNSMetrics.shared.reset()
        var query = makeQuery(name: "example.com")
        let engine = DNSEngine(zoneCache: ["example.com": "1.2.3.4"])
        _ = engine.handleQuery(buffer: &query)
        await Task.yield()
        let text = await DNSMetrics.shared.exposition()
        XCTAssertTrue(text.contains("dns_queries_total 1"))
        XCTAssertTrue(text.contains("dns_hits_total 1"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

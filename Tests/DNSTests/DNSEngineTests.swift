import XCTest
import NIOCore
import NIOEmbedded
@testable import FountainRuntime

final class DNSEngineTests: XCTestCase {
    func makeQuery(name: String, type: UInt16) -> ByteBuffer {
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
        buf.writeInteger(type, as: UInt16.self)
        buf.writeInteger(UInt16(1), as: UInt16.self)
        return buf
    }

    func testRespondsWithARecordFromCache() {
        var query = makeQuery(name: "example.com", type: 1)
        let engine = DNSEngine(records: [.init(name: "example.com", type: "A", value: "1.2.3.4")])
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

    func testRespondsWithAAAARecordFromCache() {
        var query = makeQuery(name: "ipv6.com", type: 28)
        let engine = DNSEngine(records: [.init(name: "ipv6.com", type: "AAAA", value: "2001:db8::1")])
        guard var response = engine.handleQuery(buffer: &query) else {
            XCTFail("Expected response")
            return
        }
        response.moveReaderIndex(forwardBy: response.readableBytes - 16)
        var bytes: [UInt8] = []
        for _ in 0..<16 { bytes.append(response.readInteger(as: UInt8.self)!) }
        XCTAssertEqual(bytes.count, 16)
    }

    func testRespondsWithCNAMERecordFromCache() {
        var query = makeQuery(name: "alias.com", type: 5)
        let engine = DNSEngine(records: [.init(name: "alias.com", type: "CNAME", value: "target.com")])
        guard var response = engine.handleQuery(buffer: &query) else {
            XCTFail("Expected response")
            return
        }
        let data = response.readBytes(length: response.readableBytes) ?? []
        let target = Array("target".utf8)
        let hasTarget = data.windows(ofCount: target.count).contains { Array($0) == target }
        XCTAssertTrue(hasTarget)
    }

    func testUnknownRecordReturnsNil() {
        var query = makeQuery(name: "unknown.com", type: 1)
        let engine = DNSEngine(records: [.init(name: "example.com", type: "A", value: "1.2.3.4")])
        XCTAssertNil(engine.handleQuery(buffer: &query))
    }

    func testHandlerResolvesViaEmbeddedChannel() throws {
        let engine = DNSEngine(records: [.init(name: "example.com", type: "A", value: "1.2.3.4")])
        let channel = EmbeddedChannel(handler: DNSHandler(engine: engine))
        let query = makeQuery(name: "example.com", type: 1)
        try channel.writeInbound(query)
        let response: ByteBuffer? = try channel.readOutbound()
        XCTAssertNotNil(response)
    }

    func testMetricsRecordedPerType() async throws {
        await DNSMetrics.shared.reset()
        var q1 = makeQuery(name: "example.com", type: 1)
        var q2 = makeQuery(name: "ipv6.com", type: 28)
        var q3 = makeQuery(name: "alias.com", type: 5)
        let engine = DNSEngine(records: [
            .init(name: "example.com", type: "A", value: "1.2.3.4"),
            .init(name: "ipv6.com", type: "AAAA", value: "2001:db8::1"),
            .init(name: "alias.com", type: "CNAME", value: "target.com")
        ])
        _ = engine.handleQuery(buffer: &q1)
        _ = engine.handleQuery(buffer: &q2)
        _ = engine.handleQuery(buffer: &q3)
        await Task.yield()
        let text = await DNSMetrics.shared.exposition()
        XCTAssertTrue(text.contains("dns_queries_type_A_total 1"))
        XCTAssertTrue(text.contains("dns_hits_type_AAAA_total 1"))
        XCTAssertTrue(text.contains("dns_hits_type_CNAME_total 1"))
    }

    func testNXDomainRecordsMiss() async throws {
        await DNSMetrics.shared.reset()
        var query = makeQuery(name: "missing.com", type: 1)
        let engine = DNSEngine(records: [])
        XCTAssertNil(engine.handleQuery(buffer: &query))
        await Task.yield()
        let text = await DNSMetrics.shared.exposition()
        XCTAssertTrue(text.contains("dns_misses_total 1"))
        XCTAssertTrue(text.contains("dns_queries_type_A_total 1"))
    }

    func testMalformedPacketRecordedAsInvalid() async throws {
        await DNSMetrics.shared.reset()
        var buf = ByteBufferAllocator().buffer(capacity: 2)
        buf.writeInteger(UInt16(0x1234), as: UInt16.self)
        let engine = DNSEngine(records: [])
        XCTAssertNil(engine.handleQuery(buffer: &buf))
        await Task.yield()
        let text = await DNSMetrics.shared.exposition()
        XCTAssertTrue(text.contains("dns_queries_type_invalid_total 1"))
        XCTAssertTrue(text.contains("dns_misses_total 1"))
    }

    func testHandlerDropsNXDomainQuery() throws {
        let engine = DNSEngine(records: [])
        let channel = EmbeddedChannel(handler: DNSHandler(engine: engine))
        let query = makeQuery(name: "unknown.com", type: 1)
        try channel.writeInbound(query)
        let response: ByteBuffer? = try channel.readOutbound()
        XCTAssertNil(response)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import NIOCore
@testable import FountainRuntime

final class DNSPerformanceTests: XCTestCase {
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

    func testConcurrentQueries() async {
        await DNSMetrics.shared.reset()
        let wrapper = EngineWrapper(engine: DNSEngine(zoneCache: ["example.com": "1.2.3.4"]))
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1000 {
                group.addTask {
                    await wrapper.query("example.com")
                }
            }
        }
        let finished = await DNSMetrics.shared.wait(forQueries: 1000)
        XCTAssertTrue(finished)
        let text = await DNSMetrics.shared.exposition()
        XCTAssertTrue(text.contains("dns_queries_total 1000"))
        await DNSMetrics.shared.reset()
    }

    actor EngineWrapper {
        let engine: DNSEngine
        init(engine: DNSEngine) { self.engine = engine }
        func query(_ name: String) {
            var query = DNSPerformanceTests.makeQuery(name: name)
            _ = engine.handleQuery(buffer: &query)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import NIOCore
@testable import FountainCodex

final class DNSIntegrationTests: XCTestCase {
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

    @MainActor
    func testZoneManagerFeedsDNSEngine() async throws {
        let dir = FileManager.default.temporaryDirectory
        let file = dir.appendingPathComponent(UUID().uuidString)
        let manager = try ZoneManager(fileURL: file)
        try await manager.set(name: "example.com", ip: "1.2.3.4")
        let engine = DNSEngine(zoneCache: await manager.allRecords())
        var query = Self.makeQuery(name: "example.com")
        let response = engine.handleQuery(buffer: &query)
        XCTAssertNotNil(response)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import NIOCore
@testable import FountainRuntime

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
        let zone = try await manager.createZone(name: "example.com")
        _ = try await manager.createRecord(zoneId: zone.id, name: "", type: "A", value: "1.2.3.4")
        let engine = await DNSEngine(zoneManager: manager)
        var query = Self.makeQuery(name: "example.com")
        let response = engine.handleQuery(buffer: &query)
        XCTAssertNotNil(response)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

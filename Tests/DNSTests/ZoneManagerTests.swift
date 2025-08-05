import XCTest
@testable import FountainCodex
import Yams

final class ZoneManagerTests: XCTestCase {
    func temporaryFile() -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent(UUID().uuidString)
    }

    func testLoadsExistingZonesFromDisk() async throws {
        let file = temporaryFile()
        try "example.com: 1.2.3.4\n".write(to: file, atomically: true, encoding: .utf8)
        let manager = try ZoneManager(fileURL: file)
        let ip = await manager.ip(for: "example.com")
        XCTAssertEqual(ip, "1.2.3.4")
    }

    func testPersistsUpdatesToDisk() async throws {
        let file = temporaryFile()
        let manager = try ZoneManager(fileURL: file)
        try await manager.set(name: "example.com", ip: "5.6.7.8")
        let contents = try String(contentsOf: file, encoding: .utf8)
        let yaml = try Yams.load(yaml: contents) as? [String: String]
        XCTAssertEqual(yaml?["example.com"], "5.6.7.8")
    }

    func testConcurrentUpdatesAreSerialized() async throws {
        let file = temporaryFile()
        let manager = try ZoneManager(fileURL: file)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    try await manager.set(name: "host\(i).test", ip: "1.1.1.\(i)")
                }
            }
            try await group.waitForAll()
        }
        let records = await manager.allRecords()
        XCTAssertEqual(records.count, 10)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

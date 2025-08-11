import XCTest
@testable import FountainCodex
import Yams
import Foundation

final class ZoneManagerTests: XCTestCase {
    func temporaryFile() -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent(UUID().uuidString)
    }

    func testLoadsExistingZonesFromDisk() async throws {
        let file = temporaryFile()
        let record = ZoneManager.Record(id: UUID(), name: "", type: "A", value: "1.2.3.4")
        let zone = ZoneManager.Zone(id: UUID(), name: "example.com", records: [record.id: record])
        let yaml = try YAMLEncoder().encode([zone.id: zone])
        try yaml.write(to: file, atomically: true, encoding: .utf8)
        let manager = try ZoneManager(fileURL: file)
        let ip = await manager.ip(for: "example.com")
        XCTAssertEqual(ip, "1.2.3.4")
    }

    func testPersistsUpdatesToDisk() async throws {
        let file = temporaryFile()
        let manager = try ZoneManager(fileURL: file)
        let zone = try await manager.createZone(name: "example.com")
        _ = try await manager.createRecord(zoneId: zone.id, name: "", type: "A", value: "5.6.7.8")
        let contents = try String(contentsOf: file, encoding: .utf8)
        let decoded = try YAMLDecoder().decode([UUID: ZoneManager.Zone].self, from: contents)
        XCTAssertEqual(decoded[zone.id]?.records.values.first?.value, "5.6.7.8")
    }

    func testConcurrentUpdatesAreSerialized() async throws {
        let file = temporaryFile()
        let manager = try ZoneManager(fileURL: file)
        let zone = try await manager.createZone(name: "test")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    _ = try await manager.createRecord(zoneId: zone.id, name: "host\(i)", type: "A", value: "1.1.1.\(i)")
                }
            }
            try await group.waitForAll()
        }
        let records = await manager.listRecords(zoneId: zone.id)
        XCTAssertEqual(records?.count, 10)
    }

    func testReloadUpdatesCache() async throws {
        let file = temporaryFile()
        let manager = try ZoneManager(fileURL: file)
        let zone = try await manager.createZone(name: "example.com")
        _ = try await manager.createRecord(zoneId: zone.id, name: "", type: "A", value: "1.1.1.1")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let record = ZoneManager.Record(id: UUID(), name: "", type: "A", value: "2.2.2.2")
        let newZone = ZoneManager.Zone(id: zone.id, name: "example.com", records: [record.id: record])
        let yaml = try YAMLEncoder().encode([zone.id: newZone])
        try yaml.write(to: file, atomically: true, encoding: .utf8)
        await manager.reload()
        let ip = await manager.ip(for: "example.com")
        XCTAssertEqual(ip, "2.2.2.2")
    }

    func testSetCommitsChangesToGit() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("zones.yaml")
        try "".write(to: file, atomically: true, encoding: .utf8)
        let initTask = Process()
        initTask.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        initTask.currentDirectoryURL = dir
        initTask.arguments = ["init"]
        try initTask.run()
        initTask.waitUntilExit()
        let manager = try ZoneManager(fileURL: file)
        let zone = try await manager.createZone(name: "example.com")
        _ = try await manager.createRecord(zoneId: zone.id, name: "", type: "A", value: "3.3.3.3")
        let logTask = Process()
        logTask.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        logTask.currentDirectoryURL = dir
        logTask.arguments = ["log", "--oneline"]
        let pipe = Pipe()
        logTask.standardOutput = pipe
        try logTask.run()
        logTask.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("Update zone file"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

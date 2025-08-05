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

    func testReloadUpdatesCache() async throws {
        let file = temporaryFile()
        try "example.com: 1.1.1.1\n".write(to: file, atomically: true, encoding: .utf8)
        let manager = try ZoneManager(fileURL: file)
        try "example.com: 2.2.2.2\n".write(to: file, atomically: true, encoding: .utf8)
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
        try await manager.set(name: "example.com", ip: "3.3.3.3")
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

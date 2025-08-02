import XCTest
@testable import gateway_server

final class CertificateManagerTests: XCTestCase {
    /// Executes the renewal script immediately when `triggerNow` is invoked.
    func testTriggerNowRunsScript() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("cert_test")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let logURL = dir.appendingPathComponent("log.txt")
        let scriptURL = dir.appendingPathComponent("renew.sh")
        let script = "#!/bin/sh\necho ran >> \(logURL.path)\n"
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)
        let manager = CertificateManager(scriptPath: scriptURL.path, interval: 60)
        manager.triggerNow()
        // Wait briefly for the process to complete
        sleep(1)
        let exists = FileManager.default.fileExists(atPath: logURL.path)
        XCTAssertTrue(exists)
    }

    /// Ensures that calling `start` schedules repeated executions of the script.
    func testStartSchedulesRepeatedRuns() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("cert_start")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let logURL = dir.appendingPathComponent("log.txt")
        let scriptURL = dir.appendingPathComponent("renew.sh")
        let script = "#!/bin/sh\necho tick >> \(logURL.path)\n"
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)
        let manager = CertificateManager(scriptPath: scriptURL.path, interval: 0.2)
        manager.start()
        sleep(1)
        manager.stop()
        let content = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertGreaterThan(content.split(separator: "\n").count, 1)
    }

    /// Verifies `stop` prevents further scheduled executions after cancellation.
    func testStopCancelsFutureRuns() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("cert_stop")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let logURL = dir.appendingPathComponent("log.txt")
        let scriptURL = dir.appendingPathComponent("renew.sh")
        let script = "#!/bin/sh\necho ping >> \(logURL.path)\n"
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)
        let manager = CertificateManager(scriptPath: scriptURL.path, interval: 0.2)
        manager.start()
        sleep(1)
        manager.stop()
        let first = try String(contentsOf: logURL, encoding: .utf8).split(separator: "\n").count
        sleep(1)
        let second = try String(contentsOf: logURL, encoding: .utf8).split(separator: "\n").count
        XCTAssertEqual(first, second)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
@testable import gateway_server

final class CertificateManagerTests: XCTestCase {
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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

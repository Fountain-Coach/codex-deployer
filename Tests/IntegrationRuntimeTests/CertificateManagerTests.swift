import XCTest
@testable import gateway_server
import PublishingFrontend

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
        // Allow any in-flight executions to finish before measuring.
        sleep(1)
        let first = try String(contentsOf: logURL, encoding: .utf8).split(separator: "\n").count
        sleep(1)
        let second = try String(contentsOf: logURL, encoding: .utf8).split(separator: "\n").count
        XCTAssertEqual(first, second)
    }

    /// Ensures ACME issuance publishes required DNS records.
    func testIssueCertificatePublishesDNSRecord() async throws {
        final class MockDNS: DNSProvider {
            var records: [(String, String, String, String)] = []
            func listZones() async throws -> [String] { [] }
            func createRecord(zone: String, name: String, type: String, value: String) async throws {
                records.append((zone, name, type, value))
            }
            func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws {}
            func deleteRecord(id: String) async throws {}
        }

        struct MockACME: ACMEClient {
            func createAccount(email: String) async throws {}
            func createOrder(for domain: String) async throws -> ACMEOrder { ACMEOrder() }
            func fetchDNSChallenges(order: ACMEOrder) async throws -> [DNSChallenge] {
                [DNSChallenge(recordName: "_acme-challenge.example.com", recordValue: "token")]
            }
            func validate(order: ACMEOrder) async throws {}
            func finalize(order: ACMEOrder, domains: [String]) async throws -> ACMEOrder { order }
            func downloadCertificates(order: ACMEOrder) async throws -> [String] { ["cert"] }
        }

        let manager = CertificateManager()
        let dns = MockDNS()
        let certs = try await manager.issueCertificate(for: "example.com", email: "a@b.com", dns: dns, acme: MockACME())
        XCTAssertEqual(certs, ["cert"])
        XCTAssertEqual(dns.records.count, 1)
        let rec = dns.records[0]
        XCTAssertEqual(rec.0, "example.com")
        XCTAssertEqual(rec.1, "_acme-challenge.example.com")
        XCTAssertEqual(rec.2, "TXT")
        XCTAssertEqual(rec.3, "token")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import PublishingFrontend

final class PublishingFrontendTests: XCTestCase {
    @MainActor
    func testServerServesIndex() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("public")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let indexURL = dir.appendingPathComponent("index.html")
        try "hello".write(to: indexURL, atomically: true, encoding: .utf8)
        var cfg = PublishingConfig()
        cfg.rootPath = dir.path
        cfg.port = 9099
        let frontend = PublishingFrontend(config: cfg)
        try await frontend.start()
        let url = URL(string: "http://127.0.0.1:\(cfg.port)/")!
        let data = try Data(contentsOf: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "hello")
        try await frontend.stop()
    }

    func testLoadPublishingConfigParsesYaml() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("cfg", isDirectory: true)
        let configDir = dir.appendingPathComponent("Configuration", isDirectory: true)
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        let fileURL = configDir.appendingPathComponent("publishing.yml")
        let yaml = """
        port: 1234
        rootPath: /tmp/Public
        """
        try yaml.write(to: fileURL, atomically: true, encoding: .utf8)
        let cwd = FileManager.default.currentDirectoryPath
        defer { FileManager.default.changeCurrentDirectoryPath(cwd) }
        FileManager.default.changeCurrentDirectoryPath(dir.path)
        let config = try loadPublishingConfig()
        XCTAssertEqual(config.port, 1234)
        XCTAssertEqual(config.rootPath, "/tmp/Public")
    }

    func testPublishingConfigDefaultValues() throws {
        let config = PublishingConfig()
        XCTAssertEqual(config.port, 8085)
        XCTAssertEqual(config.rootPath, "./Public")
    }

    /// Verifies custom initializer values are stored.
    func testPublishingConfigCustomValues() throws {
        let config = PublishingConfig(port: 123, rootPath: "/tmp/Docs")
        XCTAssertEqual(config.port, 123)
        XCTAssertEqual(config.rootPath, "/tmp/Docs")
    }

    /// Ensures loading the configuration without a file fails.
    func testLoadPublishingConfigFailsForMissingFile() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("nocfg", isDirectory: true)
        try? FileManager.default.removeItem(at: dir)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let cwd = FileManager.default.currentDirectoryPath
        defer { FileManager.default.changeCurrentDirectoryPath(cwd) }
        FileManager.default.changeCurrentDirectoryPath(dir.path)
        XCTAssertThrowsError(try loadPublishingConfig())
    }

    @MainActor
    func testServerReturns404ForMissingFile() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("missing-public")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        var cfg = PublishingConfig()
        cfg.rootPath = dir.path
        cfg.port = 9100
        let frontend = PublishingFrontend(config: cfg)
        try await frontend.start()
        let url = URL(string: "http://127.0.0.1:\(cfg.port)/nope.html")!
        let (_, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 404)
        try await frontend.stop()
    }

    @MainActor
    func testServerRejectsNonGetRequests() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("nonget-public")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        var cfg = PublishingConfig()
        cfg.rootPath = dir.path
        cfg.port = 9101
        let frontend = PublishingFrontend(config: cfg)
        try await frontend.start()
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(cfg.port)/")!)
        request.httpMethod = "POST"
        let (_, response) = try await URLSession.shared.data(for: request)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 405)
        try await frontend.stop()
    }

    @MainActor
    /// Verifies the server sets an HTML content type for served files.
    func testServerSetsContentTypeHeader() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("ctype-public")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let indexURL = dir.appendingPathComponent("index.html")
        try "hello".write(to: indexURL, atomically: true, encoding: .utf8)
        var cfg = PublishingConfig()
        cfg.rootPath = dir.path
        cfg.port = 9102
        let frontend = PublishingFrontend(config: cfg)
        try await frontend.start()
        let url = URL(string: "http://127.0.0.1:\(cfg.port)/")!
        let (_, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type"), "text/html")
        try await frontend.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

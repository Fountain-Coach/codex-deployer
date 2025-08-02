import XCTest
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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

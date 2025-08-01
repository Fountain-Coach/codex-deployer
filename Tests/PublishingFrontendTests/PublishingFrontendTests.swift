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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

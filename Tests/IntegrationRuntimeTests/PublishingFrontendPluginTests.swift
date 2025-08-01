import XCTest
@testable import gateway_server
@testable import FountainCodex

final class PublishingFrontendPluginTests: XCTestCase {
    func testPluginServesFile() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("static")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("index.html")
        try "hi".write(to: fileURL, atomically: true, encoding: .utf8)
        let plugin = PublishingFrontendPlugin(rootPath: dir.path)
        let req = HTTPRequest(method: "GET", path: "/")
        let resp = try await plugin.respond(HTTPResponse(status: 404), for: req)
        XCTAssertEqual(resp.status, 200)
        XCTAssertEqual(String(data: resp.body, encoding: .utf8), "hi")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

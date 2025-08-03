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

    /// Passes through the original response when no file exists.
    func testPluginPassThroughWhenFileMissing() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("static-missing")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let plugin = PublishingFrontendPlugin(rootPath: dir.path)
        let req = HTTPRequest(method: "GET", path: "/missing.html")
        let resp = try await plugin.respond(HTTPResponse(status: 404), for: req)
        XCTAssertEqual(resp.status, 404)
    }

    /// Ignores non-GET requests and returns the original response.
    func testPluginIgnoresNonGETRequests() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("static-post")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("index.html")
        try "hi".write(to: fileURL, atomically: true, encoding: .utf8)
        let plugin = PublishingFrontendPlugin(rootPath: dir.path)
        let req = HTTPRequest(method: "POST", path: "/")
        let resp = try await plugin.respond(HTTPResponse(status: 404), for: req)
        XCTAssertEqual(resp.status, 404)
    }

    /// Served files include a `Content-Type` header.
    func testPluginSetsContentTypeHeader() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("static-header")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("index.html")
        try "hi".write(to: fileURL, atomically: true, encoding: .utf8)
        let plugin = PublishingFrontendPlugin(rootPath: dir.path)
        let req = HTTPRequest(method: "GET", path: "/")
        let resp = try await plugin.respond(HTTPResponse(status: 404, headers: [:]), for: req)
        XCTAssertEqual(resp.headers["Content-Type"], "text/html")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

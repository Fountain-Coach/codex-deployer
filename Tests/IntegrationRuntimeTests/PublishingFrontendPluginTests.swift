import XCTest
@testable import gateway_server
@testable import FountainRuntime

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

    /// Serves files located in nested directories relative to ``rootPath``.
    func testPluginServesNestedFile() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("static-nested")
        try? FileManager.default.removeItem(at: dir)
        let nested = dir.appendingPathComponent("pages")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let fileURL = nested.appendingPathComponent("about.html")
        try "nested".write(to: fileURL, atomically: true, encoding: .utf8)
        let plugin = PublishingFrontendPlugin(rootPath: dir.path)
        let req = HTTPRequest(method: "GET", path: "/pages/about.html")
        let resp = try await plugin.respond(HTTPResponse(status: 404), for: req)
        XCTAssertEqual(resp.status, 200)
        XCTAssertEqual(String(data: resp.body, encoding: .utf8), "nested")
    }

    /// Preserves existing headers when passing through a missing file response.
    func testPluginPreservesHeadersOnPassThrough() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("static-headers")
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let plugin = PublishingFrontendPlugin(rootPath: dir.path)
        let req = HTTPRequest(method: "GET", path: "/missing.html")
        let original = HTTPResponse(status: 404, headers: ["X-Test": "1"])
        let resp = try await plugin.respond(original, for: req)
        XCTAssertEqual(resp.status, 404)
        XCTAssertEqual(resp.headers["X-Test"], "1")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

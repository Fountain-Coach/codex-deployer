import XCTest
@testable import ToolServer

final class IntegrationTests: XCTestCase {
    func testRouterEndpointsAndOperations() async throws {
        let manifest = ToolManifest(
            image: .init(name: "img", tarball: "t.tar", sha256: "a", qcow2: "q.qcow2", qcow2_sha256: "b"),
            tools: ["imagemagick": "1"],
            operations: ["convert"]
        )
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/convert"), "imagemagick missing")
        let router = Router(adapters: ["imagemagick": ImageMagickAdapter()], manifest: manifest)
        let health = try await router.route(HTTPRequest(method: "GET", path: "/_health"))
        XCTAssertEqual(health.status, 200)
        let manifestResp = try await router.route(HTTPRequest(method: "GET", path: "/manifest"))
        XCTAssertEqual(manifestResp.status, 200)
        let request = ToolRequest(args: ["-version"], request_id: nil)
        let body = try JSONEncoder().encode(request)
        let opResp = try await router.route(HTTPRequest(method: "POST", path: "/tool/imagemagick", headers: ["Content-Type": "application/json"], body: body))
        XCTAssertEqual(opResp.status, 200)
        XCTAssertTrue(String(data: opResp.body, encoding: .utf8)?.contains("ImageMagick") ?? false)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

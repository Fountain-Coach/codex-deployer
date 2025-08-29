import XCTest
@testable import ToolsFactoryService

final class ManifestEndpointTests: XCTestCase {
    func testManifestEndpoint() async throws {
        let manifest = ToolManifest(image: .init(name: "img", tarball: "t.tar", sha256: "a", qcow2: "q.qcow2", qcow2_sha256: "b"), tools: ["swift": "1"], operations: ["swiftc"])
        let router = ToolsFactoryRouter(service: nil, adapters: [:], manifest: manifest)
        let resp = try await router.route(HTTPRequest(method: "GET", path: "/manifest"))
        XCTAssertEqual(resp.status, 200)
        let decoded = try JSONDecoder().decode(ToolManifest.self, from: resp.body)
        XCTAssertEqual(decoded.tools["swift"], "1")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

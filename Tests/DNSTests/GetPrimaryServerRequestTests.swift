import XCTest
@testable import PublishingFrontend

final class GetPrimaryServerRequestTests: XCTestCase {
    func testPathBuilderReplacesId() {
        let params = getPrimaryServerParameters(primaryserverid: "123")
        let req = getPrimaryServer(parameters: params)
        XCTAssertEqual(req.path, "/primary_servers/123")
    }

    func testMethodIsGET() {
        let params = getPrimaryServerParameters(primaryserverid: "123")
        let req = getPrimaryServer(parameters: params)
        XCTAssertEqual(req.method, "GET")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

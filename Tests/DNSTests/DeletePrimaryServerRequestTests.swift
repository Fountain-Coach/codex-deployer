import XCTest
@testable import PublishingFrontend

final class DeletePrimaryServerRequestTests: XCTestCase {
    func testPathIsCorrect() {
        let params = deletePrimaryServerParameters(primaryserverid: "123")
        let req = deletePrimaryServer(parameters: params)
        XCTAssertEqual(req.path, "/primary_servers/123")
    }

    func testMethodIsDELETE() {
        let params = deletePrimaryServerParameters(primaryserverid: "abc")
        let req = deletePrimaryServer(parameters: params)
        XCTAssertEqual(req.method, "DELETE")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

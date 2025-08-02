import XCTest
@testable import PublishingFrontend

final class CreatePrimaryServerRequestTests: XCTestCase {
    func testPathIsCorrect() {
        let req = createPrimaryServer()
        XCTAssertEqual(req.path, "/primary_servers")
    }

    func testMethodIsPOST() {
        let req = createPrimaryServer()
        XCTAssertEqual(req.method, "POST")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

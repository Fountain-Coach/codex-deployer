import XCTest
@testable import PublishingFrontend

final class GetRecordRequestTests: XCTestCase {
    func testPathBuilderReplacesRecordId() {
        let params = getRecordParameters(recordid: "abc123")
        let req = getRecord(parameters: params)
        XCTAssertEqual(req.path, "/records/abc123")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

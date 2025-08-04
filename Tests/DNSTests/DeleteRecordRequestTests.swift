import XCTest
@testable import PublishingFrontend

final class DeleteRecordRequestTests: XCTestCase {
    /// Builds a delete request and verifies HTTP method and path.
    func testDeleteRecordBuildsPathAndMethod() {
        let params = DeleteRecordParameters(recordid: "99")
        let req = DeleteRecord(parameters: params)
        XCTAssertEqual(req.method, "DELETE")
        XCTAssertEqual(req.path, "/records/99")
        XCTAssertNil(req.body)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

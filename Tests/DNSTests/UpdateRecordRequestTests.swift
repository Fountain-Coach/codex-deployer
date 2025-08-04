import XCTest
@testable import PublishingFrontend

final class UpdateRecordRequestTests: XCTestCase {
    /// Builds an update request and verifies the HTTP method and path.
    func testUpdateRecordBuildsPathAndMethod() {
        let params = UpdateRecordParameters(recordid: "42")
        let body = RecordCreate(name: "www", ttl: 60, type: "A", value: "1.2.3.4", zone_id: "z")
        let req = UpdateRecord(parameters: params, body: body)
        XCTAssertEqual(req.method, "PUT")
        XCTAssertEqual(req.path, "/records/42")
    }

    /// Ensures body data is stored on the request.
    func testUpdateRecordStoresBody() {
        let params = UpdateRecordParameters(recordid: "1")
        let body = RecordCreate(name: "foo", ttl: 120, type: "TXT", value: "bar", zone_id: "z")
        let req = UpdateRecord(parameters: params, body: body)
        XCTAssertEqual(req.body?.name, "foo")
        XCTAssertEqual(req.body?.type, "TXT")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

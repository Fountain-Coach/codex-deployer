import XCTest
@testable import PublishingFrontend

final class ListRecordsRequestTests: XCTestCase {
    func testPathBuilderEncodesQuery() {
        let params = listRecordsParameters(zoneId: "z", page: 2, perPage: 5)
        let req = listRecords(parameters: params)
        XCTAssertEqual(req.path, "/records?zone_id=z&page=2&per_page=5")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

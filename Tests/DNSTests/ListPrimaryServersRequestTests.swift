import XCTest
@testable import PublishingFrontend

final class ListPrimaryServersRequestTests: XCTestCase {
    func testPathBuilderAddsZoneIdQueryWhenProvided() {
        let params = listPrimaryServersParameters(zoneId: "abc")
        let req = listPrimaryServers(parameters: params)
        XCTAssertEqual(req.path, "/primary_servers?zone_id=abc")
    }

    func testPathBuilderWithoutZoneIdHasNoQuery() {
        let params = listPrimaryServersParameters(zoneId: nil)
        let req = listPrimaryServers(parameters: params)
        XCTAssertEqual(req.path, "/primary_servers")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

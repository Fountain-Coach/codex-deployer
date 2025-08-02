import XCTest
@testable import PublishingFrontend

final class GetZoneRequestTests: XCTestCase {
    func testPathBuilderReplacesZoneId() {
        let params = getZoneParameters(zoneid: "zone123")
        let req = getZone(parameters: params)
        XCTAssertEqual(req.path, "/zones/zone123")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

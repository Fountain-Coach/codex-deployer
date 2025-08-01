import XCTest
@testable import PublishingFrontend

final class DeleteZoneRequestTests: XCTestCase {
    func testPathBuilderEncodesZoneId() {
        let params = deleteZoneParameters(zoneid: "123")
        let req = deleteZone(parameters: params)
        XCTAssertEqual(req.path, "/zones/123")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

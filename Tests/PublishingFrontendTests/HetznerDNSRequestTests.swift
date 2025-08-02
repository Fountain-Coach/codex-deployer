import XCTest
@testable import PublishingFrontend

final class HetznerDNSRequestTests: XCTestCase {
    func testValidateZoneFileMethodIsPost() {
        let request = validateZoneFile()
        XCTAssertEqual(request.method, "POST")
    }

    func testValidateZoneFilePath() {
        let request = validateZoneFile()
        XCTAssertEqual(request.path, "/zones/file/validate")
    }

    func testUpdatePrimaryServerMethodIsPut() {
        let req = updatePrimaryServer(parameters: updatePrimaryServerParameters(primaryserverid: "123"))
        XCTAssertEqual(req.method, "PUT")
    }

    func testUpdatePrimaryServerPathIncludesID() {
        let req = updatePrimaryServer(parameters: updatePrimaryServerParameters(primaryserverid: "123"))
        XCTAssertEqual(req.path, "/primary_servers/123")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

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

    func testImportZoneFileMethodIsPost() {
        let req = importZoneFile(parameters: importZoneFileParameters(zoneid: "abc"))
        XCTAssertEqual(req.method, "POST")
    }

    func testImportZoneFilePathIncludesZoneID() {
        let req = importZoneFile(parameters: importZoneFileParameters(zoneid: "abc"))
        XCTAssertEqual(req.path, "/zones/abc/import")
    }

    func testExportZoneFileMethodIsGet() {
        let req = exportZoneFile(parameters: exportZoneFileParameters(zoneid: "xyz"))
        XCTAssertEqual(req.method, "GET")
    }

    func testExportZoneFilePathIncludesZoneID() {
        let req = exportZoneFile(parameters: exportZoneFileParameters(zoneid: "xyz"))
        XCTAssertEqual(req.path, "/zones/xyz/export")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

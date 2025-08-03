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

    /// Verifies the bulk record creation request uses POST.
    func testBulkCreateRecordsMethodIsPost() {
        let req = bulkCreateRecords()
        XCTAssertEqual(req.method, "POST")
    }

    /// Ensures the bulk record creation request hits the correct endpoint.
    func testBulkCreateRecordsPath() {
        let req = bulkCreateRecords()
        XCTAssertEqual(req.path, "/records/bulk")
    }

    /// Verifies the create zone request uses POST.
    func testCreateZoneMethodIsPost() {
        let req = createZone()
        XCTAssertEqual(req.method, "POST")
    }

    /// Ensures the create zone request targets the zones endpoint.
    func testCreateZonePath() {
        let req = createZone()
        XCTAssertEqual(req.path, "/zones")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

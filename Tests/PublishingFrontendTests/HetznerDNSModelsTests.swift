import XCTest
@testable import PublishingFrontend

final class HetznerDNSModelsTests: XCTestCase {
    /// Encoding and decoding round-trip for `BulkRecordsCreateRequest` retains records.
    func testBulkRecordsCreateRequestCodable() throws {
        let record = RecordCreate(name: "a", ttl: 60, type: "TXT", value: "b", zone_id: "z")
        let request = BulkRecordsCreateRequest(records: [record])
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(BulkRecordsCreateRequest.self, from: data)
        XCTAssertEqual(decoded.records.first?.name, "a")
    }

    /// Decoding `validateZoneFileResponse` extracts parsed record counts.
    func testValidateZoneFileResponseDecodes() throws {
        let json = """
        {"parsed_records":1,"valid_records":[{"created":"","id":"1","modified":"","name":"","ttl":1,"type":"A","value":"1.1.1.1","zone_id":"z"}]}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(validateZoneFileResponse.self, from: json)
        XCTAssertEqual(response.parsed_records, 1)
        XCTAssertEqual(response.valid_records.count, 1)
    }

    /// Decoding `Zone` and related responses exercises generated models.
    func testZoneResponseDecoding() throws {
        let zone = Zone(created: "c", id: "1", is_secondary_dns: false, legacy_dns_host: "h", legacy_ns: [], modified: "m", name: "n", ns: [], owner: "o", paused: false, permission: "p", project: "pr", records_count: 0, registrar: "reg", status: "s", ttl: 60, txt_verification: [:], verified: "v")
        let response = ZoneResponse(zone: zone)
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(ZoneResponse.self, from: data)
        XCTAssertEqual(decoded.zone.id, "1")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

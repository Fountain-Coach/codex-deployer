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

    /// Round-trip encoding for `BulkRecordsUpdateRequest` maintains field data.
    func testBulkRecordsUpdateRequestCodable() throws {
        let request = BulkRecordsUpdateRequest(records: [["id": "1", "value": "v"]])
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(BulkRecordsUpdateRequest.self, from: data)
        XCTAssertEqual(decoded.records.first?["id"], "1")
    }

    /// Decoding `PrimaryServersResponse` retrieves embedded server details.
    func testPrimaryServersResponseDecodes() throws {
        let json = """
        {"primary_servers":[{"address":"a","created":"c","id":"1","modified":"m","port":53,"zone_id":"z"}]}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(PrimaryServersResponse.self, from: json)
        XCTAssertEqual(response.primary_servers.first?.port, 53)
    }

    /// Encoding and decoding round-trip for `PrimaryServerCreate` preserves data.
    func testPrimaryServerCreateCodable() throws {
        let request = PrimaryServerCreate(address: "1.1.1.1", port: 53, zone_id: "z")
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(PrimaryServerCreate.self, from: data)
        XCTAssertEqual(decoded.address, "1.1.1.1")
        XCTAssertEqual(decoded.port, 53)
        XCTAssertEqual(decoded.zone_id, "z")
    }

    /// Decoding `RecordResponse` extracts the embedded record details.
    func testRecordResponseDecodes() throws {
        let json = """
        {"record":{"created":"c","id":"1","modified":"m","name":"n","ttl":60,"type":"A","value":"1.1.1.1","zone_id":"z"}}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(RecordResponse.self, from: json)
        XCTAssertEqual(response.record.name, "n")
        XCTAssertEqual(response.record.value, "1.1.1.1")
    }

    /// Encoding and decoding `ZoneCreateRequest` maintains provided values.
    func testZoneCreateRequestCodable() throws {
        let request = ZoneCreateRequest(name: "example.com", ttl: 60)
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(ZoneCreateRequest.self, from: data)
        XCTAssertEqual(decoded.name, "example.com")
        XCTAssertEqual(decoded.ttl, 60)
    }

    /// Round-trip encoding for `ZoneUpdateRequest` preserves updated values.
    func testZoneUpdateRequestCodable() throws {
        let request = ZoneUpdateRequest(name: "updated.com", ttl: 120)
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(ZoneUpdateRequest.self, from: data)
        XCTAssertEqual(decoded.name, "updated.com")
        XCTAssertEqual(decoded.ttl, 120)
    }

    /// Decoding `ZonesResponse` retrieves embedded zone list and metadata.
    func testZonesResponseDecodes() throws {
        let json = """
        {"meta":{"page":"1"},"zones":[{"created":"c","id":"1","is_secondary_dns":false,"legacy_dns_host":"h","legacy_ns":[],"modified":"m","name":"n","ns":[],"owner":"o","paused":false,"permission":"p","project":"pr","records_count":0,"registrar":"reg","status":"s","ttl":60,"txt_verification":{},"verified":"v"}]}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(ZonesResponse.self, from: json)
        XCTAssertEqual(response.zones.count, 1)
        XCTAssertEqual(response.meta["page"], "1")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

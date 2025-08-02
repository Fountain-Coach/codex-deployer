import XCTest
@testable import PublishingFrontend

final class Route53ClientTests: XCTestCase {
    func testListZonesThrows() async {
        let client = Route53Client()
        do {
            _ = try await client.listZones()
            XCTFail("Expected error")
        } catch {
            let ns = error as NSError
            XCTAssertEqual(ns.domain, "Route53")
            XCTAssertEqual(ns.code, 501)
        }
    }

    func testCreateRecordThrows() async {
        let client = Route53Client()
        do {
            try await client.createRecord(zone: "z", name: "n", type: "A", value: "v")
            XCTFail("Expected error")
        } catch {
            let ns = error as NSError
            XCTAssertEqual(ns.domain, "Route53")
            XCTAssertEqual(ns.code, 501)
        }
    }

    func testUpdateRecordThrows() async {
        let client = Route53Client()
        do {
            try await client.updateRecord(id: "1", zone: "z", name: "n", type: "A", value: "v")
            XCTFail("Expected error")
        } catch {
            let ns = error as NSError
            XCTAssertEqual(ns.domain, "Route53")
            XCTAssertEqual(ns.code, 501)
        }
    }

    func testDeleteRecordThrows() async {
        let client = Route53Client()
        do {
            try await client.deleteRecord(id: "1")
            XCTFail("Expected error")
        } catch {
            let ns = error as NSError
            XCTAssertEqual(ns.domain, "Route53")
            XCTAssertEqual(ns.code, 501)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
@testable import PublishingFrontend

final class DNSClientTests: XCTestCase {
    func testRoute53Stub() async throws {
        let client = Route53Client()
        do {
            _ = try await client.listZones()
            XCTFail("expected failure")
        } catch {
            // expected not implemented
        }
    }

    func testRoute53CreateRecordStub() async throws {
        let client = Route53Client()
        do {
            try await client.createRecord(zone: "z", name: "n", type: "A", value: "v")
            XCTFail("expected failure")
        } catch {
            // expected
        }
    }

    func testRoute53UpdateRecordStub() async throws {
        let client = Route53Client()
        do {
            try await client.updateRecord(id: "1", zone: "z", name: "n", type: "A", value: "v")
            XCTFail("expected failure")
        } catch {
            // expected
        }
    }

    func testRoute53DeleteRecordStub() async throws {
        let client = Route53Client()
        do {
            try await client.deleteRecord(id: "1")
            XCTFail("expected failure")
        } catch {
            // expected
        }
    }

    func testRoute53ListZonesErrorDetails() async throws {
        let client = Route53Client()
        do {
            _ = try await client.listZones()
            XCTFail("expected failure")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    func testRoute53DeleteRecordErrorDetails() async throws {
        let client = Route53Client()
        do {
            try await client.deleteRecord(id: "1")
            XCTFail("expected failure")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    /// Verifies Route53 stub create record throws unimplemented error details.
    func testRoute53CreateRecordErrorDetails() async throws {
        let client = Route53Client()
        do {
            try await client.createRecord(zone: "z", name: "n", type: "A", value: "v")
            XCTFail("expected failure")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    /// Verifies Route53 stub update record throws unimplemented error details.
    func testRoute53UpdateRecordErrorDetails() async throws {
        let client = Route53Client()
        do {
            try await client.updateRecord(id: "1", zone: "z", name: "n", type: "A", value: "v")
            XCTFail("expected failure")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

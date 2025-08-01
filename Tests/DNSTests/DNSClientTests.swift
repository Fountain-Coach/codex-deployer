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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

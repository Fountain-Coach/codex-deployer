import XCTest
@testable import PublishingFrontend

func XCTAssertThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("expected failure")
    } catch {
        errorHandler(error)
    }
}

final class DNSClientTests: XCTestCase {
    func testRoute53Stub() async throws {
        let client = Route53Client()
        await XCTAssertThrowsError(try await client.listZones()) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    func testRoute53CreateRecordStub() async throws {
        let client = Route53Client()
        await XCTAssertThrowsError(
            try await client.createRecord(zone: "z", name: "n", type: "A", value: "v")
        ) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    func testRoute53UpdateRecordStub() async throws {
        let client = Route53Client()
        await XCTAssertThrowsError(
            try await client.updateRecord(id: "1", zone: "z", name: "n", type: "A", value: "v")
        ) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    func testRoute53DeleteRecordStub() async throws {
        let client = Route53Client()
        await XCTAssertThrowsError(try await client.deleteRecord(id: "1")) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, "Route53")
            XCTAssertEqual(error.code, 501)
        }
    }

    /// Ensures Route53 errors include descriptions and no extra user info.
    func testRoute53DeleteRecordErrorDescription() async throws {
        let client = Route53Client()
        do {
            try await client.deleteRecord(id: "1")
            XCTFail("expected failure")
        } catch let error as NSError {
            XCTAssertFalse(error.localizedDescription.isEmpty)
            XCTAssertTrue(error.userInfo.isEmpty)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

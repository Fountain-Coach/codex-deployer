import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import PublishingFrontend

final class HetznerDNSClientTests: XCTestCase {
    final class MockSession: HTTPSession {
        var lastRequest: URLRequest?
        let data: Data
        init(data: Data) { self.data = data }
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            lastRequest = request
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
            return (data, resp)
        }
    }

    func testCreateRecordRequest() async throws {
        let response = RecordResponse(record: Record(created: "", id: "1", modified: "", name: "www", ttl: 60, type: "A", value: "1.2.3.4", zone_id: "z"))
        let data = try JSONEncoder().encode(response)
        let session = MockSession(data: data)
        let client = HetznerDNSClient(token: "t", session: session)
        try await client.createRecord(zone: "z", name: "www", type: "A", value: "1.2.3.4")
        XCTAssertEqual(session.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(session.lastRequest?.url?.path, "/api/v1/records")
        XCTAssertEqual(session.lastRequest?.value(forHTTPHeaderField: "Auth-API-Token"), "t")
    }

    func testDeleteRecordRequest() async throws {
        let session = MockSession(data: Data())
        let client = HetznerDNSClient(token: "x", session: session)
        try await client.deleteRecord(id: "123")
        XCTAssertEqual(session.lastRequest?.httpMethod, "DELETE")
        XCTAssertEqual(session.lastRequest?.url?.path, "/api/v1/records/123")
    }

    func testUpdateRecordRequest() async throws {
        let response = RecordResponse(record: Record(created: "", id: "1", modified: "", name: "www", ttl: 60, type: "A", value: "2.2.2.2", zone_id: "z"))
        let data = try JSONEncoder().encode(response)
        let session = MockSession(data: data)
        let client = HetznerDNSClient(token: "t", session: session)
        try await client.updateRecord(id: "1", zone: "z", name: "www", type: "A", value: "2.2.2.2")
        XCTAssertEqual(session.lastRequest?.url?.path, "/api/v1/records/1")
        XCTAssertEqual(session.lastRequest?.httpMethod, "PUT")
    }

    func testCreateRecordSetsContentTypeHeader() async throws {
        let response = RecordResponse(record: Record(created: "", id: "1", modified: "", name: "www", ttl: 60, type: "A", value: "1.1.1.1", zone_id: "z"))
        let data = try JSONEncoder().encode(response)
        let session = MockSession(data: data)
        let client = HetznerDNSClient(token: "t", session: session)
        try await client.createRecord(zone: "z", name: "www", type: "A", value: "1.1.1.1")
        XCTAssertEqual(session.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testListZonesPathBuilder() {
        let params = ListZonesParameters(name: "foo", searchName: "bar", page: 1, perPage: 5)
        let req = ListZones(parameters: params)
        XCTAssertEqual(req.path, "/zones?name=foo&search_name=bar&page=1&per_page=5")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

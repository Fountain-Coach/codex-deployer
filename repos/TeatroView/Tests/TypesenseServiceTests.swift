import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import TypesenseClient
@testable import TeatroView

final class TypesenseServiceTests: XCTestCase {
    private struct MockSession: HTTPSession {
        let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try await handler(request)
        }
    }

    @MainActor
    func testInitFailsWithoutEnv() async {
        unsetenv("TYPESENSE_URL")
        unsetenv("TYPESENSE_API_KEY")
        XCTAssertThrowsError(try TypesenseService())
    }

    @MainActor
    func testListCollectionsRequest() async throws {
        setenv("TYPESENSE_URL", "http://localhost:8108", 1)
        setenv("TYPESENSE_API_KEY", "abc", 1)
        let expected: [CollectionResponse] = []
        let data = try JSONEncoder().encode(expected)
        let session = MockSession { req in
            XCTAssertEqual(req.url?.path, "/collections")
            XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer abc")
            return (data, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = try TypesenseService(session: session)
        let resp = try await service.listCollections()
        XCTAssertEqual(resp.count, 0)
    }

    @MainActor
    func testUpdateSchema() async throws {
        setenv("TYPESENSE_URL", "http://localhost:8108", 1)
        setenv("TYPESENSE_API_KEY", "abc", 1)
        let schemaData = "{\"name\":\"books\",\"fields\":[]}".data(using: .utf8)!
        let schema = try JSONDecoder().decode(CollectionUpdateSchema.self, from: schemaData)
        let data = try JSONEncoder().encode(schema)
        let session = MockSession { req in
            XCTAssertEqual(req.httpMethod, "PATCH")
            XCTAssertEqual(req.url?.path, "/collections/foo")
            return (data, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = try TypesenseService(session: session)
        _ = try await service.updateSchema(collection: "foo", schema: schema)
    }

    @MainActor
    func testHealthRequest() async throws {
        setenv("TYPESENSE_URL", "http://localhost:8108", 1)
        setenv("TYPESENSE_API_KEY", "abc", 1)
        let json = "{" + "\"ok\":true" + "}"
        let data = json.data(using: .utf8)!
        _ = try JSONDecoder().decode(HealthStatus.self, from: data)
        let session = MockSession { req in
            XCTAssertEqual(req.url?.path, "/health")
            return (data, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = try TypesenseService(session: session)
        let resp = try await service.fetchHealth()
        XCTAssertTrue(resp.ok)
    }

    @MainActor
    func testAPIStatsRequest() async throws {
        setenv("TYPESENSE_URL", "http://localhost:8108", 1)
        setenv("TYPESENSE_API_KEY", "abc", 1)
        let json = "{" +
            "\"delete_latency_ms\":\"0\"," +
            "\"delete_requests_per_second\":\"0\"," +
            "\"import_latency_ms\":\"0\"," +
            "\"import_requests_per_second\":\"0\"," +
            "\"latency_ms\":{}," +
            "\"overloaded_requests_per_second\":\"0\"," +
            "\"pending_write_batches\":\"0\"," +
            "\"requests_per_second\":{}," +
            "\"search_latency_ms\":\"1\"," +
            "\"search_requests_per_second\":\"1\"," +
            "\"total_requests_per_second\":\"1\"," +
            "\"write_latency_ms\":\"0\"," +
            "\"write_requests_per_second\":\"0\"" +
        "}"
        let data = json.data(using: .utf8)!
        _ = try JSONDecoder().decode(APIStatsResponse.self, from: data)
        let session = MockSession { req in
            XCTAssertEqual(req.url?.path, "/stats.json")
            return (data, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = try TypesenseService(session: session)
        let resp = try await service.apiStats()
        XCTAssertEqual(resp.search_latency_ms, "1")
    }
}

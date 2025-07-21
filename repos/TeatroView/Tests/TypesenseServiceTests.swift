import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import TypesenseClient
@testable import TeatroUI

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
}

import XCTest
@testable import TeatroViewCore
import TypesenseClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


final class TypesenseServiceTests: XCTestCase {
    private struct MockSession: HTTPSession {
        let handler: (URLRequest) async throws -> (Data, URLResponse)
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try await handler(request)
        }
    }

    func testInitFailsWithoutEnv() async {
        unsetenv("TYPESENSE_URL")
        unsetenv("TYPESENSE_API_KEY")
        XCTAssertThrowsError(try TypesenseService())
    }

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

    func testUpdateSchema() async throws {
        setenv("TYPESENSE_URL", "http://localhost:8108", 1)
        setenv("TYPESENSE_API_KEY", "abc", 1)
        let schemaData = "{\"fields\":[]}".data(using: .utf8)!
        let schema = try JSONDecoder().decode(CollectionUpdateSchema.self, from: schemaData)
        let data = try JSONEncoder().encode(schema)
        var captured: URLRequest?
        let session = MockSession { req in
            captured = req
            return (data, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = try TypesenseService(session: session)
        _ = try await service.updateSchema(collection: "foo", schema: schema)
        XCTAssertEqual(captured?.httpMethod, "PATCH")
        XCTAssertEqual(captured?.url?.path, "/collections/foo")
    }
}

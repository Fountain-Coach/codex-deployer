import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import PublishingFrontend

final class APIClientTests: XCTestCase {
    final class MockSession: HTTPSession {
        var request: URLRequest?
        let responseData: Data
        init(responseData: Data) { self.responseData = responseData }
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            self.request = request
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (responseData, resp)
        }
    }

    func testSendDecodesResponse() async throws {
        struct Echo: APIRequest {
            typealias Response = String
            var method: String { "GET" }
            var path: String { "/echo" }
            var body: NoBody? = nil
        }
        let data = try JSONEncoder().encode("hello")
        let session = MockSession(responseData: data)
        let client = APIClient(baseURL: URL(string: "http://localhost")!, session: session, defaultHeaders: ["X-Test": "1"]) 
        let result: String = try await client.send(Echo())
        XCTAssertEqual(result, "hello")
        XCTAssertEqual(session.request?.value(forHTTPHeaderField: "X-Test"), "1")
    }

    func testBearerInitializerSetsHeader() async throws {
        struct Ping: APIRequest {
            typealias Response = NoBody
            var method: String { "GET" }
            var path: String { "/ping" }
            var body: NoBody? = nil
        }
        let session = MockSession(responseData: Data())
        let client = APIClient(baseURL: URL(string: "http://localhost")!, bearerToken: "abc", session: session)
        _ = try await client.send(Ping())
        XCTAssertEqual(session.request?.value(forHTTPHeaderField: "Authorization"), "Bearer abc")
    }

    func testRawDataResponse() async throws {
        struct DataEcho: APIRequest {
            struct Payload: Encodable { let msg: String }
            typealias Body = Payload
            typealias Response = Data
            var method: String { "POST" }
            var path: String { "/echo" }
            var body: Payload? = Payload(msg: "hi")
        }
        let expected = Data([1, 2, 3])
        let session = MockSession(responseData: expected)
        let client = APIClient(baseURL: URL(string: "http://localhost")!, session: session)
        let result: Data = try await client.send(DataEcho())
        XCTAssertEqual(result, expected)
        XCTAssertEqual(session.request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

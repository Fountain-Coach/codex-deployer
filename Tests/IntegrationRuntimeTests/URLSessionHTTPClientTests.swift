import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import NIOCore
import NIOHTTP1
@testable import FountainCodex

final class URLSessionHTTPClientTests: XCTestCase {
    private class MockURLProtocol: URLProtocol {
        nonisolated(unsafe) static var handler: (@Sendable (URLRequest) -> (HTTPURLResponse, Data))?
        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        override func startLoading() {
            guard let handler = MockURLProtocol.handler else { return }
            let (resp, data) = handler(request)
            client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        override func stopLoading() {}
    }

    func testExecutePerformsRequest() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "1")
            let body = String(data: request.httpBody ?? Data(), encoding: .utf8)
            XCTAssertEqual(body, "hi")
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["X-Reply": "ok"])! 
            return (resp, Data("pong".utf8))
        }
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        buffer.writeString("hi")
        let client = URLSessionHTTPClient(session: session)
        let (data, headers) = try await client.execute(method: .POST, url: "http://localhost", headers: HTTPHeaders([("X-Test", "1")]), body: buffer)
        XCTAssertEqual(data.getString(at: 0, length: data.readableBytes), "pong")
        XCTAssertEqual(headers.first(name: "X-Reply"), "ok")
    }

    func testExecuteHandlesEmptyBody() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertNil(request.httpBody)
            let resp = HTTPURLResponse(url: request.url!, statusCode: 204, httpVersion: nil, headerFields: [:])!
            return (resp, Data())
        }
        let client = URLSessionHTTPClient(session: session)
        let (data, headers) = try await client.execute(method: .GET, url: "http://localhost", body: nil)
        XCTAssertEqual(data.readableBytes, 0)
        XCTAssertTrue(headers.isEmpty)
    }

    func testExecuteCollectsMultipleHeaders() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        MockURLProtocol.handler = { request in
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["X-A": "a", "X-B": "b"])!
            return (resp, Data())
        }
        let client = URLSessionHTTPClient(session: session)
        let (_, headers) = try await client.execute(method: .GET, url: "http://localhost", body: nil)
        XCTAssertEqual(headers.first(name: "X-A"), "a")
        XCTAssertEqual(headers.first(name: "X-B"), "b")
    }

    func testExecuteThrowsOnInvalidURL() async {
        let client = URLSessionHTTPClient()
        do {
            _ = try await client.execute(method: .GET, url: "not a url", body: nil)
            XCTFail("Expected to throw")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .badURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SBCore

final class IndexingTests: XCTestCase {
    private class MockURLProtocol: URLProtocol {
        nonisolated(unsafe) static var requests: [URLRequest] = []

        static func bodyData(from request: URLRequest) -> Data {
            if let body = request.httpBody { return body }
            guard let stream = request.httpBodyStream else { return Data() }
            stream.open()
            defer { stream.close() }
            var data = Data()
            let bufferSize = 1024
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            while stream.hasBytesAvailable {
                let read = stream.read(&buffer, maxLength: buffer.count)
                if read > 0 { data.append(buffer, count: read) } else { break }
            }
            return data
        }

        override class func canInit(with request: URLRequest) -> Bool {
            request.url?.host == "localhost"
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            MockURLProtocol.requests.append(request)
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data())
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }

    override func setUp() {
        super.setUp()
        _ = URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.requests = []
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }

    func testUpsertSendsDocuments() async throws {
        let html = "<p>Hello Bob</p>"
        let snapshot = SnapshotBuilder().build(
            url: URL(string: "https://example.com")!,
            status: 200,
            contentType: "text/html",
            html: html,
            text: "Hello Bob"
        )
        let analysis = try await Dissector().analyze(from: snapshot, mode: .deep, store: nil)

        var options = IndexOptions(enabled: true)
        options.pagesCollection = "pages"
        options.segmentsCollection = "segments"
        options.entitiesCollection = "entities"
        options.typesense = .init(url: URL(string: "http://localhost"), apiKey: "key", timeoutMs: nil)

        let result = try await TypesenseIndexer().upsert(analysis: analysis, options: options)

        XCTAssertEqual(result.pagesUpserted, 1)
        XCTAssertEqual(result.segmentsUpserted, analysis.blocks.count)
        XCTAssertEqual(result.entitiesUpserted, analysis.semantics?.entities?.count)

        XCTAssertEqual(MockURLProtocol.requests.count, 3)
        let pageRequest = MockURLProtocol.requests[0]
        XCTAssertEqual(pageRequest.httpMethod, "POST")
        XCTAssertEqual(pageRequest.value(forHTTPHeaderField: "X-TYPESENSE-API-KEY"), "key")
        let bodyData = MockURLProtocol.bodyData(from: pageRequest)
        let lines = String(decoding: bodyData, as: UTF8.self).split(separator: "\n")
        let pageDoc = try JSONDecoder().decode(PageDoc.self, from: Data(lines[0].utf8))
        XCTAssertEqual(pageDoc.id, analysis.envelope.id)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

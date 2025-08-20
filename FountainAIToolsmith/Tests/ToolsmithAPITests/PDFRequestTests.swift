import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import ToolsmithAPI

final class PDFRequestTests: XCTestCase {
    final class MockSession: HTTPSession {
        var lastRequest: URLRequest?
        var responseData: Data

        init(responseData: Data) {
            self.responseData = responseData
        }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            lastRequest = request
            let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: responseData.count, textEncodingName: nil)
            return (responseData, response)
        }
    }

    func testPDFScanRequestFormation() async throws {
        let indexJSON = try JSONEncoder().encode(Index(documents: []))
        let session = MockSession(responseData: indexJSON)
        let client = APIClient(baseURL: URL(string: "http://example.com")!, session: session)
        let body = ScanRequest(includeText: true, inputs: ["doc.pdf"], sha256: false)
        _ = try await client.send(pdfScan(body: body))
        XCTAssertEqual(session.lastRequest?.url?.path, "/pdf/scan")
        XCTAssertEqual(session.lastRequest?.httpMethod, "POST")
        if let data = session.lastRequest?.httpBody {
            let sent = try JSONDecoder().decode(ScanRequest.self, from: data)
            XCTAssertEqual(sent.inputs, ["doc.pdf"])
        } else {
            XCTFail("Missing body")
        }
    }

    func testPDFQueryRequestFormation() async throws {
        let respJSON = try JSONEncoder().encode(QueryResponse(hits: []))
        let session = MockSession(responseData: respJSON)
        let client = APIClient(baseURL: URL(string: "http://example.com")!, session: session)
        let doc = IndexedDocument(id: "1", fileName: "doc.pdf", size: 1, sha256: nil, pages: nil)
        let index = Index(documents: [doc])
        let body = QueryRequest(index: index, pageRange: "1", q: "test")
        _ = try await client.send(pdfQuery(body: body))
        XCTAssertEqual(session.lastRequest?.url?.path, "/pdf/query")
        if let data = session.lastRequest?.httpBody {
            let sent = try JSONDecoder().decode(QueryRequest.self, from: data)
            XCTAssertEqual(sent.q, "test")
        } else {
            XCTFail("Missing body")
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

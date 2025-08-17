import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import LLMGatewayService

final class SentinelConsultHandlerTests: XCTestCase {
    private class StubProtocol: URLProtocol {
        nonisolated(unsafe) static var decision = "allow"
        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        override func startLoading() {
            let json = """
            {"choices":[{"message":{"content":"\(StubProtocol.decision)"}}]}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: json)
            client?.urlProtocolDidFinishLoading(self)
        }
        override func stopLoading() {}
    }

    override func setUp() {
        _ = URLProtocol.registerClass(StubProtocol.self)
        setenv("OPENAI_API_KEY", "test", 1)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(StubProtocol.self)
    }

    private func consult(decision: String) async throws -> String {
        StubProtocol.decision = decision
        let requestBody = SecurityCheckRequest(resources: [], summary: "danger", user: "user")
        let data = try JSONEncoder().encode(requestBody)
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult", body: data)
        let resp = try await Handlers().sentinelconsult(request, body: requestBody)
        let decisionResp = try JSONDecoder().decode(SecurityDecision.self, from: resp.body)
        return decisionResp.decision
    }

    func testAllow() async throws {
        let result = try await consult(decision: "allow")
        XCTAssertEqual(result, "allow")
    }

    func testDeny() async throws {
        let result = try await consult(decision: "deny")
        XCTAssertEqual(result, "deny")
    }

    func testEscalate() async throws {
        let result = try await consult(decision: "escalate")
        XCTAssertEqual(result, "escalate")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

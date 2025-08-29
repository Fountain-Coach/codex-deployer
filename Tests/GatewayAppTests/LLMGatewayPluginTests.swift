import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import LLMGatewayPlugin
import FountainRuntime
import gateway_server

final class LLMGatewayPluginTests: XCTestCase {
    func testSentinelConsultDecisions() async throws {
        let plugin = LLMGatewayPlugin()
        let reqBody = SecurityCheckRequest(summary: "please delete", user: "u", resources: [])
        let data = try JSONEncoder().encode(reqBody)
        let request = HTTPRequest(method: "POST", path: "/sentinel/consult", body: data)
        let resp = try await plugin.router.route(request)
        let decision = try JSONDecoder().decode(SecurityDecision.self, from: resp!.body)
        XCTAssertEqual(decision.decision, "deny")

        let allowBody = SecurityCheckRequest(summary: "safe action", user: "u", resources: [])
        let allowData = try JSONEncoder().encode(allowBody)
        let allowReq = HTTPRequest(method: "POST", path: "/sentinel/consult", body: allowData)
        let allowResp = try await plugin.router.route(allowReq)
        let allowDecision = try JSONDecoder().decode(SecurityDecision.self, from: allowResp!.body)
        XCTAssertEqual(allowDecision.decision, "allow")
    }

    func testChatWithObjective() async throws {
        let plugin = LLMGatewayPlugin()
        let chat = ChatRequest(model: "gpt", messages: [MessageObject(role: "user", content: "hi")], include_cot: true)
        let data = try JSONEncoder().encode(chat)
        let req = HTTPRequest(method: "POST", path: "/chat", body: data)
        let resp = try await plugin.router.route(req)
        let obj = try JSONSerialization.jsonObject(with: resp!.body) as? [String: Any]
        XCTAssertNotNil(obj?["id"])
        XCTAssertNotNil(obj?["cot"])
    }

    func testGetChatCoTRoleRedaction() async throws {
        let logURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let entry = ["id": "chat-1", "cot": "my secret plan"]
        let data = try JSONSerialization.data(withJSONObject: entry)
        let line = String(data: data, encoding: .utf8)! + "\n"
        try line.write(to: logURL, atomically: true, encoding: .utf8)
        let plugin = LLMGatewayPlugin(cotLogURL: logURL)
        let devReq = HTTPRequest(method: "GET", path: "/chat/chat-1/cot", headers: ["X-User-Role": "developer"])
        let devResp = try await plugin.router.route(devReq)
        let devObj = try JSONSerialization.jsonObject(with: devResp!.body) as? [String: Any]
        XCTAssertEqual(devObj?["cot"] as? String, "my [REDACTED] plan")

        let userReq = HTTPRequest(method: "GET", path: "/chat/chat-1/cot", headers: ["X-User-Role": "user"])
        let userResp = try await plugin.router.route(userReq)
        let userObj = try JSONSerialization.jsonObject(with: userResp!.body) as? [String: Any]
        XCTAssertNotNil(userObj?["cot_summary"] as? String)
        XCTAssertNil(userObj?["cot"])
    }

    func testMetricsEndpoint() async throws {
        let plugin = LLMGatewayPlugin()
        let req = HTTPRequest(method: "GET", path: "/metrics")
        let resp = try await plugin.router.route(req)
        XCTAssertEqual(resp?.status, 200)
        let body = String(data: resp!.body, encoding: .utf8)!
        XCTAssertTrue(body.contains("llm_gateway_uptime_seconds"))
    }

    @MainActor
    func testSentinelRoutePriorityAndMetrics() async throws {
        let upstreamKernel = HTTPKernel { _ in HTTPResponse(status: 200, body: Data("upstream".utf8)) }
        let upstream = NIOHTTPServer(kernel: upstreamKernel)
        let upstreamPort = try await upstream.start(port: 0)

        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let route = Route(id: "s", path: "/sentinel", target: "http://127.0.0.1:\(upstreamPort)", methods: ["POST"], rateLimit: nil, proxyEnabled: true)
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try JSONEncoder().encode([route]).write(to: file)

        let plugin = LLMGatewayPlugin()
        let server = GatewayServer(plugins: [plugin], routeStoreURL: file)
        let port = 9151
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        let before = await GatewayRequestMetrics.shared.snapshot()

        var req = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/sentinel/consult")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = SecurityCheckRequest(summary: "safe", user: "u", resources: [])
        req.httpBody = try JSONEncoder().encode(body)
        let (data, resp) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 200)
        let decision = try JSONDecoder().decode(SecurityDecision.self, from: data)
        XCTAssertEqual(decision.decision, "allow")

        let after = await GatewayRequestMetrics.shared.snapshot()
        let key = "gateway_responses_status_200_total"
        XCTAssertEqual((after[key] ?? 0) - (before[key] ?? 0), 1)

        try await server.stop()
        try await upstream.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

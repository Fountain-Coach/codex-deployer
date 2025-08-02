import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server
@testable import FountainCodex

final class GatewayServerTests: XCTestCase {

    @MainActor
    func testHealthEndpointResponds() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9100) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9100/health")!
        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        let body = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(body?["status"], "ok")
        try await server.stop()
    }

    @MainActor
    func testMetricsEndpointResponds() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9101) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9101/metrics")!
        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        let body = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
        XCTAssertNotNil(body?["metrics"])
        try await server.stop()
    }

    @MainActor
    func testPluginCanRewriteRequestAndResponse() async throws {
        struct RewritePlugin: GatewayPlugin {
            func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
                if request.path == "/ping" {
                    return HTTPRequest(method: request.method, path: "/health", headers: request.headers, body: request.body)
                }
                return request
            }
            func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
                var res = response
                res.headers["X-Rewritten"] = "true"
                return res
            }
        }
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [RewritePlugin()])
        Task { try await server.start(port: 9102) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9102/ping")!
        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        let header = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-Rewritten")
        XCTAssertEqual(header, "true")
        let body = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(body?["status"], "ok")
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

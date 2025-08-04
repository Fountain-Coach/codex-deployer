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

    @MainActor
    /// Unknown paths should yield a `404` status.
    func testUnknownPathReturns404() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9103) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9103/unknown")!
        let (_, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 404)
        try await server.stop()
    }

    @MainActor
    /// Plugins should receive the response in reverse order of registration.
    func testPluginsRespondInReverseOrder() async throws {
        actor OrderCollector {
            private var names: [String] = []
            func record(_ name: String) { names.append(name) }
            func snapshot() -> [String] { names }
        }
        struct RecordingPlugin: GatewayPlugin {
            let name: String
            let collector: OrderCollector
            func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
                await collector.record(name)
                return response
            }
        }
        let collector = OrderCollector()
        let plugins: [GatewayPlugin] = [
            RecordingPlugin(name: "A", collector: collector),
            RecordingPlugin(name: "B", collector: collector)
        ]
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: plugins)
        Task { try await server.start(port: 9104) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9104/health")!
        _ = try await URLSession.shared.data(from: url)
        try await server.stop()
        let order = await collector.snapshot()
        XCTAssertEqual(order, ["B", "A"])
    }

    @MainActor
    /// Plugins should run `prepare` in registration order.
    func testPluginsPrepareInRegistrationOrder() async throws {
        actor OrderCollector {
            private var names: [String] = []
            func record(_ name: String) { names.append(name) }
            func snapshot() -> [String] { names }
        }
        struct RecordingPlugin: GatewayPlugin {
            let name: String
            let collector: OrderCollector
            func prepare(_ request: HTTPRequest) async throws -> HTTPRequest {
                await collector.record(name)
                return request
            }
        }
        let collector = OrderCollector()
        let plugins: [GatewayPlugin] = [
            RecordingPlugin(name: "A", collector: collector),
            RecordingPlugin(name: "B", collector: collector)
        ]
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: plugins)
        Task { try await server.start(port: 9105) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9105/health")!
        _ = try await URLSession.shared.data(from: url)
        try await server.stop()
        let order = await collector.snapshot()
        XCTAssertEqual(order, ["A", "B"])
    }

    @MainActor
    /// Health endpoint should emit the JSON content type header.
    func testHealthEndpointSetsJSONContentType() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9106) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9106/health")!
        let (_, response) = try await URLSession.shared.data(from: url)
        let header = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(header, "application/json")
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

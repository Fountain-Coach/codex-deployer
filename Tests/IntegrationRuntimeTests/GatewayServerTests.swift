import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server

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
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

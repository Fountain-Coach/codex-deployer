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

    @MainActor
    /// Metrics endpoint should emit the JSON content type header.
    func testMetricsEndpointSetsJSONContentType() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9107) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9107/metrics")!
        let (_, response) = try await URLSession.shared.data(from: url)
        let header = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(header, "application/json")
        try await server.stop()
    }

    @MainActor
    /// Metrics endpoint should return an empty metrics array by default.
    func testMetricsEndpointReturnsEmptyArray() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9108) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9108/metrics")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let body = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
        XCTAssertEqual(body?["metrics"], [])
        try await server.stop()
    }

    @MainActor
    /// Zone creation should validate request schema.
      func testZoneEndpointValidatesSchema() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9109) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9109/zones")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        struct Zone: Encodable { let name: String }
        request.httpBody = try JSONEncoder().encode(Zone(name: "example"))
        var (data, response) = try await URLSession.shared.data(for: request)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 201)
        let body = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(body?["name"], "example")
        request.httpBody = Data("{}".utf8)
        (_, response) = try await URLSession.shared.data(for: request)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 400)
        try await server.stop()
    }

    @MainActor
    func testZoneLifecycle() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9110) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let base = URL(string: "http://127.0.0.1:9110")!
        struct ZoneCreate: Encodable { let name: String }
        var request = URLRequest(url: base.appendingPathComponent("zones"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ZoneCreate(name: "example"))
        var (data, response) = try await URLSession.shared.data(for: request)
        struct Zone: Decodable { let id: String; let name: String }
        let created = try JSONDecoder().decode(Zone.self, from: data)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 201)
        let listURL = base.appendingPathComponent("zones")
        (data, response) = try await URLSession.shared.data(from: listURL)
        struct ZonesResponse: Decodable { let zones: [Zone] }
        var zones = try JSONDecoder().decode(ZonesResponse.self, from: data)
        XCTAssertEqual(zones.zones.count, 1)
        let deleteURL = base.appendingPathComponent("zones/\(created.id)")
        var deleteReq = URLRequest(url: deleteURL)
        deleteReq.httpMethod = "DELETE"
        (_, response) = try await URLSession.shared.data(for: deleteReq)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 204)
        (data, _) = try await URLSession.shared.data(from: listURL)
        zones = try JSONDecoder().decode(ZonesResponse.self, from: data)
        XCTAssertEqual(zones.zones.count, 0)
        try await server.stop()
    }

    @MainActor
    func testRecordLifecycle() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9111) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let base = URL(string: "http://127.0.0.1:9111")!
        struct ZoneCreate: Encodable { let name: String }
        var zoneReq = URLRequest(url: base.appendingPathComponent("zones"))
        zoneReq.httpMethod = "POST"
        zoneReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        zoneReq.httpBody = try JSONEncoder().encode(ZoneCreate(name: "example"))
        var (data, _) = try await URLSession.shared.data(for: zoneReq)
        struct Zone: Decodable { let id: String }
        let zone = try JSONDecoder().decode(Zone.self, from: data)
        struct RecordRequest: Encodable { let name: String; let type: String; let value: String }
        var recordReq = URLRequest(url: base.appendingPathComponent("zones/\(zone.id)/records"))
        recordReq.httpMethod = "POST"
        recordReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        recordReq.httpBody = try JSONEncoder().encode(RecordRequest(name: "www", type: "A", value: "1.1.1.1"))
        (data, _) = try await URLSession.shared.data(for: recordReq)
        struct Record: Decodable { let id: String }
        let record = try JSONDecoder().decode(Record.self, from: data)
        let listURL = base.appendingPathComponent("zones/\(zone.id)/records")
        (data, _) = try await URLSession.shared.data(from: listURL)
        struct RecordsResponse: Decodable { let records: [Record] }
        var records = try JSONDecoder().decode(RecordsResponse.self, from: data)
        XCTAssertEqual(records.records.count, 1)
        let deleteURL = base.appendingPathComponent("zones/\(zone.id)/records/\(record.id)")
        var deleteReq = URLRequest(url: deleteURL)
        deleteReq.httpMethod = "DELETE"
        (_, _) = try await URLSession.shared.data(for: deleteReq)
        (data, _) = try await URLSession.shared.data(from: listURL)
        records = try JSONDecoder().decode(RecordsResponse.self, from: data)
        XCTAssertEqual(records.records.count, 0)
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

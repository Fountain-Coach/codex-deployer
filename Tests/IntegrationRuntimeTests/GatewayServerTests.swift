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
        let body = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(body.contains("dns_queries_total"))
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
    func testMetricsEndpointSetsTextContentType() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9107) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9107/metrics")!
        let (_, response) = try await URLSession.shared.data(from: url)
        let header = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(header, "text/plain")
        try await server.stop()
    }

    @MainActor
    /// Metrics endpoint should emit zero counters by default.
    func testMetricsEndpointReturnsZeroCounters() async throws {
        await DNSMetrics.shared.reset()
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9108) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let url = URL(string: "http://127.0.0.1:9108/metrics")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let body = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(body.contains("dns_queries_total 0"))
        XCTAssertTrue(body.contains("dns_hits_total 0"))
        XCTAssertTrue(body.contains("dns_misses_total 0"))
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

    @MainActor
    func testReloadEndpointTriggersZoneManager() async throws {
        let dir = FileManager.default.temporaryDirectory
        let file = dir.appendingPathComponent(UUID().uuidString)
        try "example.com: 1.1.1.1\n".write(to: file, atomically: true, encoding: .utf8)
        let zoneManager = try ZoneManager(fileURL: file)
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [], zoneManager: zoneManager)
        Task { try await server.start(port: 9112) }
        try await Task.sleep(nanoseconds: 100_000_000)
        try "example.com: 2.2.2.2\n".write(to: file, atomically: true, encoding: .utf8)
        var request = URLRequest(url: URL(string: "http://127.0.0.1:9112/zones/reload")!)
        request.httpMethod = "POST"
        let (_, response) = try await URLSession.shared.data(for: request)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 204)
        let ip = await zoneManager.ip(for: "example.com")
        XCTAssertEqual(ip, "2.2.2.2")
        try await server.stop()
    }

    @MainActor
    func testAuthTokenEndpointResponds() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9113) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let base = URL(string: "http://127.0.0.1:9113")!
        var request = URLRequest(url: base.appendingPathComponent("auth/token"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        struct Creds: Encodable { let clientId: String; let clientSecret: String }
        request.httpBody = try JSONEncoder().encode(Creds(clientId: "admin", clientSecret: "password"))
        let (data, response) = try await URLSession.shared.data(for: request)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        let body = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertNotNil(body?["token"])
        try await server.stop()
    }

    @MainActor
    func testRoutesCRUD() async throws {
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9114) }
        try await Task.sleep(nanoseconds: 100_000_000)
        let base = URL(string: "http://127.0.0.1:9114")!
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int? }
        var create = URLRequest(url: base.appendingPathComponent("routes"))
        create.httpMethod = "POST"
        create.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let route = Route(id: "r1", path: "/foo", target: "http://upstream", methods: ["GET"], rateLimit: nil)
        create.httpBody = try JSONEncoder().encode(route)
        var (data, response) = try await URLSession.shared.data(for: create)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 201)
        (data, response) = try await URLSession.shared.data(from: base.appendingPathComponent("routes"))
        var list = try JSONDecoder().decode([Route].self, from: data)
        XCTAssertEqual(list.count, 1)
        var update = URLRequest(url: base.appendingPathComponent("routes/r1"))
        update.httpMethod = "PUT"
        update.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let updated = Route(id: "ignored", path: "/bar", target: "http://up", methods: ["POST"], rateLimit: 5)
        update.httpBody = try JSONEncoder().encode(updated)
        (data, response) = try await URLSession.shared.data(for: update)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        var deleteReq = URLRequest(url: base.appendingPathComponent("routes/r1"))
        deleteReq.httpMethod = "DELETE"
        (_, response) = try await URLSession.shared.data(for: deleteReq)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 204)
        (data, _) = try await URLSession.shared.data(from: base.appendingPathComponent("routes"))
        list = try JSONDecoder().decode([Route].self, from: data)
        XCTAssertEqual(list.count, 0)
        try await server.stop()
    }

    @MainActor
    func testProxyRoutesForwardToUpstream() async throws {
        // Start upstream server returning a known payload
        let upstreamKernel = HTTPKernel { req in
            let body = Data("upstream:\\(req.path)".utf8)
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain", "X-Upstream": "yes"], body: body)
        }
        let upstream = NIOHTTPServer(kernel: upstreamKernel)
        let upstreamPort = try await upstream.start(port: 0)

        // Start gateway
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9115) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Create route mapping /api -> upstream
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        var create = URLRequest(url: URL(string: "http://127.0.0.1:9115/routes")!)
        create.httpMethod = "POST"
        create.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let r = Route(id: "u1", path: "/api", target: "http://127.0.0.1:\(upstreamPort)/api", methods: ["GET"], rateLimit: nil, proxyEnabled: true)
        create.httpBody = try JSONEncoder().encode(r)
        _ = try await URLSession.shared.data(for: create)

        // Request through gateway and verify upstream response propagated
        let url = URL(string: "http://127.0.0.1:9115/api/hello?x=1")!
        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        let body = String(decoding: data, as: UTF8.self)
        fputs("[test] proxy body: \(body)\n", stderr)
        XCTAssertTrue(body.contains("/api/hello"), "body=\(body)")
        XCTAssertEqual((response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-Upstream"), "yes")

        try await upstream.stop()
        try await server.stop()
    }

    @MainActor
    func testProxyRateLimitEnforced() async throws {
        let upstreamKernel = HTTPKernel { _ in HTTPResponse(status: 200) }
        let upstream = NIOHTTPServer(kernel: upstreamKernel)
        let upstreamPort = try await upstream.start(port: 0)

        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9116) }
        try await Task.sleep(nanoseconds: 100_000_000)

        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        var create = URLRequest(url: URL(string: "http://127.0.0.1:9116/routes")!)
        create.httpMethod = "POST"
        create.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let r = Route(id: "rl1", path: "/lim", target: "http://127.0.0.1:\(upstreamPort)/lim", methods: ["GET"], rateLimit: 1, proxyEnabled: true)
        create.httpBody = try JSONEncoder().encode(r)
        _ = try await URLSession.shared.data(for: create)

        let url = URL(string: "http://127.0.0.1:9116/lim/a")!
        var (_, resp1) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((resp1 as? HTTPURLResponse)?.statusCode, 200)
        // Immediate second request should exceed 1 rps
        var (_, resp2) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((resp2 as? HTTPURLResponse)?.statusCode, 429)

        try await upstream.stop()
        try await server.stop()
    }

    @MainActor
    func testProxyDisabledSkipsForwarding() async throws {
        let upstreamKernel = HTTPKernel { _ in HTTPResponse(status: 200) }
        let upstream = NIOHTTPServer(kernel: upstreamKernel)
        _ = try await upstream.start(port: 0)

        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [])
        Task { try await server.start(port: 9117) }
        try await Task.sleep(nanoseconds: 100_000_000)

        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        var create = URLRequest(url: URL(string: "http://127.0.0.1:9117/routes")!)
        create.httpMethod = "POST"
        create.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let r = Route(id: "d1", path: "/off", target: "http://127.0.0.1:9/off", methods: ["GET"], rateLimit: nil, proxyEnabled: false)
        create.httpBody = try JSONEncoder().encode(r)
        _ = try await URLSession.shared.data(for: create)

        let url = URL(string: "http://127.0.0.1:9117/off/anything")!
        let (_, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 404)

        try await server.stop()
        try await upstream.stop()
    }

    @MainActor
    func testRoutesPersistAcrossRestart() async throws {
        // Create a temporary file for route persistence
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")

        // Start server A with persistence
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let serverA = GatewayServer(manager: manager, plugins: [], zoneManager: nil, routeStoreURL: file)
        Task { try await serverA.start(port: 9118) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Create a route
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        var create = URLRequest(url: URL(string: "http://127.0.0.1:9118/routes")!)
        create.httpMethod = "POST"
        create.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let r = Route(id: "persist1", path: "/p", target: "http://u/p", methods: ["GET"], rateLimit: nil, proxyEnabled: true)
        create.httpBody = try JSONEncoder().encode(r)
        _ = try await URLSession.shared.data(for: create)

        // Stop server A
        try await serverA.stop()
        try await Task.sleep(nanoseconds: 50_000_000)

        // Start server B with same persistence file
        let serverB = GatewayServer(manager: manager, plugins: [], zoneManager: nil, routeStoreURL: file)
        Task { try await serverB.start(port: 9119) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Verify the route is present
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:9119/routes")!)
        let list = try JSONDecoder().decode([Route].self, from: data)
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.first?.id, "persist1")

        try await serverB.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

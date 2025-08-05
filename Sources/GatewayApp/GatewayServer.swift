import Foundation
import NIO
import NIOHTTP1
import FountainCodex

/// HTTP gateway server that composes plugins for request handling.
/// Provides built-in `/health` and `/metrics` endpoints used for monitoring.
/// Additionally exposes control plane endpoints with basic schema validation.
@MainActor
public final class GatewayServer {
    /// Underlying HTTP server handling TCP connections.
    private let server: NIOHTTPServer
    /// Manages periodic certificate renewal scripts.
    private let manager: CertificateManager
    /// Event loop group powering the SwiftNIO server.
    private let group: EventLoopGroup
    /// Middleware components executed around request routing.
    /// Plugins run in registration order during ``GatewayPlugin.prepare(_:)``
    /// and in reverse order during ``GatewayPlugin.respond(_:for:)``.
    private let plugins: [GatewayPlugin]
    private let zoneManager: ZoneManager?

    /// In-memory zone model.
    private struct Zone: Codable { let id: UUID; let name: String }
    private struct ZonesResponse: Codable { let zones: [Zone] }
    private struct ZoneCreateRequest: Codable { let name: String }

    /// DNS record model supporting core record types.
    private enum RecordType: String, Codable { case A, AAAA, CNAME, MX, TXT, SRV, CAA }
    private struct Record: Codable { let id: UUID; let name: String; let type: RecordType; let value: String }
    private struct RecordRequest: Codable { let name: String; let type: RecordType; let value: String }
    private struct RecordsResponse: Codable { let records: [Record] }


    /// Creates a new gateway server instance.
    /// - Parameters:
    ///   - manager: Certificate renewal manager.
    ///   - plugins: Plugins applied before and after routing.
    ///     Plugins are invoked in the order provided for ``GatewayPlugin.prepare(_:)``
    ///     and in reverse order for ``GatewayPlugin.respond(_:for:)``.
    public init(manager: CertificateManager = CertificateManager(),
                plugins: [GatewayPlugin] = [],
                zoneManager: ZoneManager? = nil) {
        self.manager = manager
        self.plugins = plugins
        self.zoneManager = zoneManager
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        var zones: [UUID: Zone] = [:]
        var records: [UUID: [UUID: Record]] = [:]
        let kernel = HTTPKernel { [plugins, zoneManager] req in
            var request = req
            for plugin in plugins {
                request = try await plugin.prepare(request)
            }
            let segments = request.path.split(separator: "/", omittingEmptySubsequences: true)
            var response: HTTPResponse
            switch (request.method, segments) {
            case ("GET", ["health"]):
                let json = try JSONEncoder().encode(["status": "ok"])
                response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            case ("GET", ["metrics"]):
                let metrics: [String: [String]] = ["metrics": []]
                let json = try JSONEncoder().encode(metrics)
                response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            case ("GET", ["zones"]):
                let json = try JSONEncoder().encode(ZonesResponse(zones: Array(zones.values)))
                response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            case ("POST", ["zones"]):
                do {
                    let req = try JSONDecoder().decode(ZoneCreateRequest.self, from: request.body)
                    let zone = Zone(id: UUID(), name: req.name)
                    zones[zone.id] = zone
                    let json = try JSONEncoder().encode(zone)
                    response = HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)
                } catch {
                    response = HTTPResponse(status: 400)
                }
            case ("POST", ["zones", "reload"]):
                if let manager = zoneManager {
                    await manager.reload()
                    response = HTTPResponse(status: 204)
                } else {
                    response = HTTPResponse(status: 500)
                }
            case ("DELETE", let seg) where seg.count == 2 && seg[0] == "zones":
                let zoneId = seg[1]
                if let id = UUID(uuidString: String(zoneId)), zones.removeValue(forKey: id) != nil {
                    records[id] = nil
                    response = HTTPResponse(status: 204)
                } else {
                    response = HTTPResponse(status: 404)
                }
            case ("GET", let seg) where seg.count == 3 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = seg[1]
                if let id = UUID(uuidString: String(zoneId)), zones[id] != nil {
                    let recs = Array(records[id]?.values ?? [:].values)
                    let json = try JSONEncoder().encode(RecordsResponse(records: recs))
                    response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
                } else {
                    response = HTTPResponse(status: 404)
                }
            case ("POST", let seg) where seg.count == 3 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = seg[1]
                guard let id = UUID(uuidString: String(zoneId)), zones[id] != nil else {
                    response = HTTPResponse(status: 404)
                    break
                }
                do {
                    let req = try JSONDecoder().decode(RecordRequest.self, from: request.body)
                    let record = Record(id: UUID(), name: req.name, type: req.type, value: req.value)
                    var zoneRecords = records[id] ?? [:]
                    zoneRecords[record.id] = record
                    records[id] = zoneRecords
                    let json = try JSONEncoder().encode(record)
                    response = HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)
                } catch {
                    response = HTTPResponse(status: 400)
                }
            case ("PUT", let seg) where seg.count == 4 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = seg[1]
                let recordId = seg[3]
                guard let zid = UUID(uuidString: String(zoneId)),
                      let rid = UUID(uuidString: String(recordId)),
                      records[zid]?[rid] != nil else {
                    response = HTTPResponse(status: 404)
                    break
                }
                do {
                    let req = try JSONDecoder().decode(RecordRequest.self, from: request.body)
                    let record = Record(id: rid, name: req.name, type: req.type, value: req.value)
                    records[zid]![rid] = record
                    let json = try JSONEncoder().encode(record)
                    response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
                } catch {
                    response = HTTPResponse(status: 400)
                }
            case ("DELETE", let seg) where seg.count == 4 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = seg[1]
                let recordId = seg[3]
                if let zid = UUID(uuidString: String(zoneId)),
                   let rid = UUID(uuidString: String(recordId)),
                   records[zid]?.removeValue(forKey: rid) != nil {
                    response = HTTPResponse(status: 204)
                } else {
                    response = HTTPResponse(status: 404)
                }
            default:
                response = HTTPResponse(status: 404)
            }
            for plugin in plugins.reversed() {
                response = try await plugin.respond(response, for: request)
            }
            return response
        }
        self.server = NIOHTTPServer(kernel: kernel, group: group)
    }

    /// Starts the gateway on the given port.
    /// Begins certificate renewal scheduling before binding the SwiftNIO server.
    /// - Parameter port: TCP port to bind.
    public func start(port: Int = 8080) async throws {
        manager.start()
        _ = try await server.start(port: port)
    }

    /// Stops the server and terminates certificate renewal.
    /// Cancels the certificate manager timer and shuts down the server.
    public func stop() async throws {
        manager.stop()
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

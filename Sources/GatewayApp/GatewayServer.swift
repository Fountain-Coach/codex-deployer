import Foundation
import NIO
import NIOHTTP1
import FountainCodex
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP gateway server that composes plugins for request handling.
/// Provides built-in `/health` and `/metrics` endpoints used for monitoring.
/// Additionally exposes control plane endpoints with basic schema validation.
@MainActor
public final class GatewayServer {
    /// Underlying HTTP server handling TCP connections.
    private var server: NIOHTTPServer
    /// Manages periodic certificate renewal scripts.
    private let manager: CertificateManager
    /// Event loop group powering the SwiftNIO server.
    private let group: EventLoopGroup
    /// Middleware components executed around request routing.
    /// Plugins run in registration order during ``GatewayPlugin.prepare(_:)``
    /// and in reverse order during ``GatewayPlugin.respond(_:for:)``.
    private let plugins: [GatewayPlugin]
    private let zoneManager: ZoneManager?
    private var zones: [UUID: Zone]
    private var records: [UUID: [UUID: Record]]
    private var routes: [String: RouteInfo]
    private let routesURL: URL?

    /// In-memory zone model.
    private struct Zone: Codable { let id: UUID; let name: String }
    private struct ZonesResponse: Codable { let zones: [Zone] }
    private struct ZoneCreateRequest: Codable { let name: String }

    /// DNS record model supporting core record types.
    private enum RecordType: String, Codable { case A, AAAA, CNAME, MX, TXT, SRV, CAA }
    private struct Record: Codable { let id: UUID; let name: String; let type: RecordType; let value: String }
    private struct RecordRequest: Codable { let name: String; let type: RecordType; let value: String }
    private struct RecordsResponse: Codable { let records: [Record] }

    /// Authentication request and token response models.
    private struct CredentialRequest: Codable { let clientId: String; let clientSecret: String }
    private struct TokenResponse: Codable { let token: String; let expiresAt: String }
    private struct ErrorResponse: Codable { let error: String }

    /// Route description used for management operations.
    private struct RouteInfo: Codable {
        enum Method: String, Codable, CaseIterable { case GET, POST, PUT, PATCH, DELETE }
        let id: String
        var path: String
        var target: String
        var methods: [Method]
        var rateLimit: Int?
        var proxyEnabled: Bool?
    }



    /// Creates a new gateway server instance.
    /// - Parameters:
    ///   - manager: Certificate renewal manager.
    ///   - plugins: Plugins applied before and after routing.
    ///     Plugins are invoked in the order provided for ``GatewayPlugin.prepare(_:)``
    ///     and in reverse order for ``GatewayPlugin.respond(_:for:)``.
    public init(manager: CertificateManager = CertificateManager(),
                plugins: [GatewayPlugin] = [],
                zoneManager: ZoneManager? = nil,
                routeStoreURL: URL? = nil) {
        self.manager = manager
        self.plugins = plugins
        self.zoneManager = zoneManager
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.zones = [:]
        self.records = [:]
        self.routes = [:]
        self.routesURL = routeStoreURL
        self.server = NIOHTTPServer(kernel: HTTPKernel { _ in HTTPResponse(status: 500) }, group: group)
        self.rateLimiter = RateLimiter()
        // Load persisted routes if configured
        self.reloadRoutes()
        let kernel = HTTPKernel { [plugins, zoneManager, self] req in
            var request = req
            for plugin in plugins {
                request = try await plugin.prepare(request)
            }
            let segments = request.path.split(separator: "/", omittingEmptySubsequences: true)
            var response: HTTPResponse
            switch (request.method, segments) {
            case ("GET", ["health"]):
                response = self.gatewayHealth()
            case ("GET", ["metrics"]):
                response = await self.gatewayMetrics()
            case ("POST", ["auth", "token"]):
                response = await self.issueAuthToken(request)
            case ("GET", ["certificates"]):
                response = self.certificateInfo()
            case ("POST", ["certificates", "renew"]):
                response = self.renewCertificate()
            case ("GET", ["routes"]):
                response = self.listRoutes()
            case ("POST", ["routes"]):
                response = self.createRoute(request)
            case ("POST", ["routes", "reload"]):
                self.reloadRoutes()
                response = HTTPResponse(status: 204)
            case ("PUT", let seg) where seg.count == 2 && seg[0] == "routes":
                let id = String(seg[1])
                response = self.updateRoute(id, request: request)
            case ("DELETE", let seg) where seg.count == 2 && seg[0] == "routes":
                let id = String(seg[1])
                response = self.deleteRoute(id)
            case ("GET", ["zones"]):
                let json = try JSONEncoder().encode(ZonesResponse(zones: Array(self.zones.values)))
                response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            case ("POST", ["zones"]):
                response = await self.createZone(request)
            case ("POST", ["zones", "reload"]):
                if let manager = zoneManager {
                    await manager.reload()
                    response = HTTPResponse(status: 204)
                } else {
                    response = HTTPResponse(status: 500)
                }
            case ("DELETE", let seg) where seg.count == 2 && seg[0] == "zones":
                let zoneId = String(seg[1])
                response = self.deleteZone(zoneId)
            case ("GET", let seg) where seg.count == 3 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = String(seg[1])
                response = self.listRecords(zoneId)
            case ("POST", let seg) where seg.count == 3 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = seg[1]
                guard let id = UUID(uuidString: String(zoneId)), self.zones[id] != nil else {
                    response = HTTPResponse(status: 404)
                    break
                }
                do {
                    let req = try JSONDecoder().decode(RecordRequest.self, from: request.body)
                    let record = Record(id: UUID(), name: req.name, type: req.type, value: req.value)
                    var zoneRecords = self.records[id] ?? [:]
                    zoneRecords[record.id] = record
                    self.records[id] = zoneRecords
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
                      self.records[zid]?[rid] != nil else {
                    response = HTTPResponse(status: 404)
                    break
                }
                do {
                    let req = try JSONDecoder().decode(RecordRequest.self, from: request.body)
                    let record = Record(id: rid, name: req.name, type: req.type, value: req.value)
                    self.records[zid]![rid] = record
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
                   self.records[zid]?.removeValue(forKey: rid) != nil {
                    response = HTTPResponse(status: 204)
                } else {
                    response = HTTPResponse(status: 404)
                }
            default:
                if let proxied = try await self.tryProxy(request) {
                    response = proxied
                } else {
                    response = HTTPResponse(status: 404)
                }
            }
            for plugin in plugins.reversed() {
                response = try await plugin.respond(response, for: request)
            }
            return response
        }
        self.server = NIOHTTPServer(kernel: kernel, group: group)
    }

    /// Simple per-route token bucket rate limiter.
    private final class RateLimiter {
        private struct Bucket { var tokens: Double; var lastRefill: TimeInterval; let capacity: Double; let rate: Double }
        private var buckets: [String: Bucket] = [:]
        private var allowed = 0
        private var throttled = 0

        func stats() -> (allowed: Int, throttled: Int) { (allowed, throttled) }

        func allow(routeId: String, limitPerMinute: Int) -> Bool {
            let ratePerSecond = Double(limitPerMinute) / 60.0
            let now = Date().timeIntervalSince1970
            var bucket = buckets[routeId] ?? Bucket(tokens: Double(limitPerMinute), lastRefill: now, capacity: Double(limitPerMinute), rate: ratePerSecond)
            let elapsed = max(0, now - bucket.lastRefill)
            bucket.tokens = min(bucket.capacity, bucket.tokens + elapsed * bucket.rate)
            bucket.lastRefill = now
            if bucket.tokens >= 1.0 {
                bucket.tokens -= 1.0
                buckets[routeId] = bucket
                allowed += 1
                Task { await DNSMetrics.shared.recordRateLimit(allowed: true) }
                return true
            }
            buckets[routeId] = bucket
            throttled += 1
            Task { await DNSMetrics.shared.recordRateLimit(allowed: false) }
            return false
        }
    }
    private let rateLimiter: RateLimiter

    /// Attempts to match the incoming request against configured routes and proxy it upstream.
    /// Performs a simple prefix match on the configured path and enforces allowed methods.
    /// - Returns: A proxied response if a matching route is found; otherwise `nil`.
    private func tryProxy(_ request: HTTPRequest) async throws -> HTTPResponse? {
        // Extract path without query for matching
        let pathOnly = request.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? request.path
        guard let reqMethod = RouteInfo.Method(rawValue: request.method) else { return nil }
        // Choose the longest matching path prefix among routes
        let candidates = routes.values
            .filter { route in
                (route.methods.isEmpty || route.methods.contains(reqMethod)) &&
                ((route.proxyEnabled ?? true) == true) &&
                (pathOnly == route.path || pathOnly.hasPrefix(route.path.hasSuffix("/") ? route.path : route.path + "/"))
            }
            .sorted { $0.path.count > $1.path.count }
        guard let route = candidates.first else { return nil }

        // Rate limit if configured
        if let limit = route.rateLimit, limit > 0 {
            if !rateLimiter.allow(routeId: route.id, limitPerMinute: limit) {
                return HTTPResponse(status: 429, headers: ["Content-Type": "text/plain"], body: Data("too many requests".utf8))
            }
        }

        // Build upstream URL by joining target + suffix (keep original query string)
        let suffix = String(pathOnly.dropFirst(route.path.count))
        let query = request.path.contains("?") ? String(request.path.split(separator: "?", maxSplits: 1)[1]) : nil
        var urlString = route.target
        if !suffix.isEmpty {
            if urlString.hasSuffix("/") || suffix.hasPrefix("/") {
                urlString += suffix
            } else {
                urlString += "/" + suffix
            }
        }
        if let query, !query.isEmpty { urlString += "?" + query }
        guard let url = URL(string: urlString), url.scheme != nil else { return HTTPResponse(status: 502) }
        FileHandle.standardError.write(Data("[gateway] proxy -> \(url.absoluteString)\n".utf8))

        var upstream = URLRequest(url: url)
        upstream.httpMethod = request.method
        // Copy headers except Host; allow upstream to set it
        for (k, v) in request.headers where k.lowercased() != "host" {
            upstream.setValue(v, forHTTPHeaderField: k)
        }
        if !request.body.isEmpty { upstream.httpBody = request.body }

        do {
            let (data, resp) = try await URLSession.shared.data(for: upstream)
            let status = (resp as? HTTPURLResponse)?.statusCode ?? 200
            var headers: [String: String] = [:]
            if let http = resp as? HTTPURLResponse {
                for (key, value) in http.allHeaderFields {
                    if let k = key as? String, let v = value as? String { headers[k] = v }
                }
            }
            return HTTPResponse(status: status, headers: headers, body: data)
        } catch {
            return HTTPResponse(status: 502, headers: ["Content-Type": "text/plain"], body: Data("bad gateway".utf8))
        }
    }

    public func gatewayHealth() -> HTTPResponse {
        let json = try? JSONEncoder().encode(["status": "ok"])
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json ?? Data())
    }

    public func gatewayMetrics() async -> HTTPResponse {
        let exposition = await DNSMetrics.shared.exposition()
        var metrics: [String: Int] = [:]
        for line in exposition.split(separator: "\n") {
            let parts = line.split(separator: " ")
            if parts.count == 2, let value = Int(parts[1]) {
                metrics[String(parts[0])] = value
            }
        }
        if let json = try? JSONEncoder().encode(metrics) {
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
        }
        return HTTPResponse(status: 500)
    }

    public func issueAuthToken(_ request: HTTPRequest) async -> HTTPResponse {
        do {
            let creds = try JSONDecoder().decode(CredentialRequest.self, from: request.body)
            if creds.clientId == "admin", creds.clientSecret == "password" {
                let formatter = ISO8601DateFormatter()
                let expires = formatter.string(from: Date().addingTimeInterval(3600))
                let token = UUID().uuidString
                let json = try JSONEncoder().encode(TokenResponse(token: token, expiresAt: expires))
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            }
            let json = try JSONEncoder().encode(ErrorResponse(error: "invalid credentials"))
            return HTTPResponse(status: 401, headers: ["Content-Type": "application/json"], body: json)
        } catch {
            return HTTPResponse(status: 400)
        }
    }

    public func certificateInfo() -> HTTPResponse {
        struct CertificateInfo: Codable { let notAfter: String; let issuer: String }
        let formatter = ISO8601DateFormatter()
        let info = CertificateInfo(notAfter: formatter.string(from: Date().addingTimeInterval(86_400)), issuer: "SelfSigned")
        if let json = try? JSONEncoder().encode(info) {
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
        }
        return HTTPResponse(status: 500)
    }

    public func renewCertificate() -> HTTPResponse {
        manager.triggerNow()
        if let json = try? JSONEncoder().encode(["status": "triggered"]) {
            return HTTPResponse(status: 202, headers: ["Content-Type": "application/json"], body: json)
        }
        return HTTPResponse(status: 500)
    }

    public func listRoutes() -> HTTPResponse {
        if let json = try? JSONEncoder().encode(Array(self.routes.values)) {
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
        }
        return HTTPResponse(status: 500)
    }

    public func createRoute(_ request: HTTPRequest) -> HTTPResponse {
        do {
            let info = try JSONDecoder().decode(RouteInfo.self, from: request.body)
            if !info.methods.allSatisfy({ RouteInfo.Method.allCases.contains($0) }) {
                return HTTPResponse(status: 400)
            }
            if self.routes[info.id] == nil {
                self.routes[info.id] = info
                self.persistRoutes()
                let json = try JSONEncoder().encode(info)
                return HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)
            }
            let json = try JSONEncoder().encode(ErrorResponse(error: "exists"))
            return HTTPResponse(status: 409, headers: ["Content-Type": "application/json"], body: json)
        } catch {
            return HTTPResponse(status: 400)
        }
    }

    public func updateRoute(_ routeId: String, request: HTTPRequest) -> HTTPResponse {
        guard self.routes[routeId] != nil else {
            if let json = try? JSONEncoder().encode(ErrorResponse(error: "not found")) {
                return HTTPResponse(status: 404, headers: ["Content-Type": "application/json"], body: json)
            }
            return HTTPResponse(status: 404)
        }
        do {
            let info = try JSONDecoder().decode(RouteInfo.self, from: request.body)
            guard info.methods.allSatisfy({ RouteInfo.Method.allCases.contains($0) }) else {
                return HTTPResponse(status: 400)
            }
            let updated = RouteInfo(id: routeId, path: info.path, target: info.target, methods: info.methods, rateLimit: info.rateLimit, proxyEnabled: info.proxyEnabled)
            self.routes[routeId] = updated
            self.persistRoutes()
            let json = try JSONEncoder().encode(updated)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
        } catch {
            return HTTPResponse(status: 400)
        }
    }

    public func deleteRoute(_ routeId: String) -> HTTPResponse {
        if self.routes.removeValue(forKey: routeId) != nil {
            self.persistRoutes()
            return HTTPResponse(status: 204)
        }
        if let json = try? JSONEncoder().encode(ErrorResponse(error: "not found")) {
            return HTTPResponse(status: 404, headers: ["Content-Type": "application/json"], body: json)
        }
        return HTTPResponse(status: 404)
    }

    private func persistRoutes() {
        guard let url = routesURL else { return }
        do {
            let list = Array(self.routes.values)
            let data = try JSONEncoder().encode(list)
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let temp = dir.appendingPathComponent(UUID().uuidString)
            try data.write(to: temp)
            if FileManager.default.fileExists(atPath: url.path) {
                _ = try FileManager.default.replaceItemAt(url, withItemAt: temp)
            } else {
                try FileManager.default.moveItem(at: temp, to: url)
            }
        } catch {
            FileHandle.standardError.write(Data("[gateway] Warning: failed to persist routes to \(url.path): \(error)\n".utf8))
        }
    }

    public func reloadRoutes() {
        guard let url = routesURL else { return }
        do {
            let data = try Data(contentsOf: url)
            let loaded = try JSONDecoder().decode([RouteInfo].self, from: data)
            self.routes = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        } catch {
            FileHandle.standardError.write(Data("[gateway] Warning: failed to reload routes from \(url.path): \(error)\n".utf8))
        }
    }

    public func createZone(_ request: HTTPRequest) async -> HTTPResponse {
        do {
            let req = try JSONDecoder().decode(ZoneCreateRequest.self, from: request.body)
            let zone = Zone(id: UUID(), name: req.name)
            self.zones[zone.id] = zone
            let json = try JSONEncoder().encode(zone)
            return HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)
        } catch {
            return HTTPResponse(status: 400)
        }
    }

    public func deleteZone(_ zoneId: String) -> HTTPResponse {
        if let id = UUID(uuidString: zoneId), self.zones.removeValue(forKey: id) != nil {
            self.records[id] = nil
            return HTTPResponse(status: 204)
        }
        return HTTPResponse(status: 404)
    }

    public func listRecords(_ zoneId: String) -> HTTPResponse {
        if let id = UUID(uuidString: zoneId), self.zones[id] != nil {
            let recs = Array(self.records[id]?.values ?? [UUID: Record]().values)
            if let json = try? JSONEncoder().encode(RecordsResponse(records: recs)) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            }
            return HTTPResponse(status: 500)
        }
        return HTTPResponse(status: 404)
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

import Foundation
import NIO
import NIOHTTP1
import FountainRuntime
import Crypto
import X509
import LLMGatewayPlugin
import AuthGatewayPlugin
import RateLimiterGatewayPlugin
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
    private let roleGuardStore: RoleGuardStore?
    private var routes: [String: RouteInfo]
    private let routesURL: URL?
    private let certificatePath: String?
    private let rateLimiter: RateLimiterGatewayPlugin?
    private let breaker: CircuitBreaker = CircuitBreaker()
    private var roleGuardReloader: RoleGuardConfigReloader?

    private struct ZoneCreateRequest: Codable { let name: String }
    private struct ZonesResponse: Codable { let zones: [ZoneManager.Zone] }
    /// DNS record model supporting core record types.
    private enum RecordType: String, Codable { case A, AAAA, CNAME, MX, TXT, SRV, CAA }
    private struct RecordRequest: Codable { let name: String; let type: RecordType; let value: String }
    private struct RecordsResponse: Codable { let records: [ZoneManager.Record] }

    /// Authentication request and token response models.
    private struct CredentialRequest: Codable { let clientId: String; let clientSecret: String }
    private struct TokenResponse: Codable { let token: String; let expiresAt: String }
    private struct ErrorResponse: Codable { let error: String }

    /// Encodes an error message as JSON and sets the appropriate content type.
    /// - Parameters:
    ///   - status: HTTP status code to return.
    ///   - message: Human-readable error description.
    private func error(_ status: Int, message: String) -> HTTPResponse {
        let body = (try? JSONEncoder().encode(ErrorResponse(error: message))) ?? Data()
        return HTTPResponse(status: status, headers: ["Content-Type": "application/json"], body: body)
    }

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
                routeStoreURL: URL? = nil,
                certificatePath: String? = nil,
                rateLimiter: RateLimiterGatewayPlugin? = nil,
                roleGuardStore: RoleGuardStore? = nil) {
        self.manager = manager
        self.plugins = plugins
        self.zoneManager = zoneManager
        self.roleGuardStore = roleGuardStore
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.routes = [:]
        self.routesURL = routeStoreURL
        self.certificatePath = certificatePath
        self.server = NIOHTTPServer(kernel: HTTPKernel { _ in HTTPResponse(status: 500) }, group: group)
        self.rateLimiter = rateLimiter
        // Load persisted routes if configured
        self.reloadRoutes()
        let kernel = HTTPKernel { [plugins, zoneManager, self] req in
            var request = req
            do {
                for plugin in plugins {
                    request = try await plugin.prepare(request)
                }
            } catch is UnauthorizedError {
                return HTTPResponse(status: 401)
            } catch is ForbiddenError {
                return HTTPResponse(status: 403)
            } catch is TooManyRequestsError {
                return HTTPResponse(status: 429, headers: ["Content-Type": "text/plain"], body: Data("too many requests".utf8))
            } catch is ServiceUnavailableError {
                return HTTPResponse(status: 503, headers: ["Content-Type": "text/plain"], body: Data("service unavailable".utf8))
            }

            // Allow plugins with routers to handle requests before builtin routes.
            for plugin in plugins {
                if let llm = plugin as? LLMGatewayPlugin,
                   let handled = try await llm.router.route(request) {
                    return handled
                }
                if let auth = plugin as? AuthGatewayPlugin,
                   let handled = try await auth.router.route(request) {
                    return handled
                }
            }
            let segments = request.path.split(separator: "/", omittingEmptySubsequences: true)
            var response: HTTPResponse
            let start = Date()
            switch (request.method, segments) {
            case ("GET", ["health"]):
                response = self.gatewayHealth()
            case ("GET", ["live"]):
                response = self.gatewayLiveness()
            case ("GET", ["ready"]):
                response = self.gatewayReadiness()
            case ("GET", ["metrics"]):
                response = await self.gatewayMetrics()
            case ("GET", ["roleguard"]):
                response = await self.listRoleGuardRules()
            case ("POST", ["roleguard", "reload"]):
                response = await self.reloadRoleGuardRules()
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
                if let manager = zoneManager {
                    let zones = await manager.listZones()
                    let json = try JSONEncoder().encode(ZonesResponse(zones: zones))
                    response = HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
                } else {
                    response = self.error(500, message: "zone manager unavailable")
                }
            case ("POST", ["zones"]):
                response = await self.createZone(request)
            case ("DELETE", let seg) where seg.count == 2 && seg[0] == "zones":
                let zoneId = String(seg[1])
                response = await self.deleteZone(zoneId)
            case ("GET", let seg) where seg.count == 3 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = String(seg[1])
                response = await self.listRecords(zoneId)
            case ("POST", let seg) where seg.count == 3 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = seg[1]
                response = await self.createRecord(String(zoneId), request: request)
            case ("PUT", let seg) where seg.count == 4 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = String(seg[1])
                let recordId = String(seg[3])
                response = await self.updateRecord(zoneId, recordId: recordId, request: request)
            case ("DELETE", let seg) where seg.count == 4 && seg[0] == "zones" && seg[2] == "records":
                let zoneId = String(seg[1])
                let recordId = String(seg[3])
                response = await self.deleteRecord(zoneId, recordId: recordId)
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
            // Record metrics and emit a structured log line
            await GatewayRequestMetrics.shared.record(method: request.method, status: response.status)
            let durMs = Int(Date().timeIntervalSince(start) * 1000)
            let log: [String: Any] = [
                "ts": ISO8601DateFormatter().string(from: Date()),
                "evt": "http_access",
                "method": request.method,
                "path": request.path,
                "status": response.status,
                "duration_ms": durMs
            ]
            if let data = try? JSONSerialization.data(withJSONObject: log), let line = String(data: data, encoding: .utf8) {
                FileHandle.standardError.write(Data((line + "\n").utf8))
            }
            return response
        }
        self.server = NIOHTTPServer(kernel: kernel, group: group)
        // Kick off RoleGuard config polling if possible
        if let store = roleGuardStore {
            Task { @MainActor in
                if let reloader = await RoleGuardConfigReloader(store: store) {
                    self.roleGuardReloader = reloader
                    reloader.start(interval: 2.0)
                }
            }
        }
    }

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

        // Apply rate limiting if a plugin is available
        if let rateLimiter {
            var clientId = "anonymous"
            if let auth = request.headers["Authorization"], auth.hasPrefix("Bearer ") {
                let token = String(auth.dropFirst(7))
                let store = CredentialStore()
                clientId = store.subject(for: token) ?? clientId
            }
            let allowed = await rateLimiter.allow(routeId: route.id, clientId: clientId, limitPerMinute: route.rateLimit)
            if !allowed {
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
        let breakerKey = "\(route.id)::\(url.scheme ?? "")://\(url.host ?? "")"
        if await !breaker.allow(key: breakerKey) {
            return HTTPResponse(status: 503, headers: ["Content-Type": "text/plain"], body: Data("service unavailable".utf8))
        }
        FileHandle.standardError.write(Data("[gateway] proxy -> \(url.absoluteString)\n".utf8))

        var upstream = URLRequest(url: url)
        upstream.httpMethod = request.method
        // Copy safe headers, let URLSession manage hop-by-hop and payload framing
        for (k, v) in request.headers {
            let lk = k.lowercased()
            if lk == "host" || lk == "content-length" || lk == "transfer-encoding" || lk == "connection" || lk == "expect" { continue }
            upstream.setValue(v, forHTTPHeaderField: k)
        }
        if !request.body.isEmpty { upstream.httpBody = request.body }

        do {
            let (data, resp) = try await URLSession.shared.data(for: upstream)
            await breaker.recordSuccess(key: breakerKey)
            let status = (resp as? HTTPURLResponse)?.statusCode ?? 200
            var headers: [String: String] = [:]
            if let http = resp as? HTTPURLResponse {
                for (key, value) in http.allHeaderFields {
                    if let k = key as? String, let v = value as? String { headers[k] = v }
                }
            }
            return HTTPResponse(status: status, headers: headers, body: data)
        } catch {
            await breaker.recordFailure(key: breakerKey)
            return HTTPResponse(status: 502, headers: ["Content-Type": "text/plain"], body: Data("bad gateway".utf8))
        }
    }

    public func gatewayHealth() -> HTTPResponse {
        let json = try? JSONEncoder().encode(["status": "ok"])
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json ?? Data())
    }

    public func gatewayLiveness() -> HTTPResponse {
        let json = try? JSONEncoder().encode(["status": "live"]) 
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json ?? Data())
    }

    public func gatewayReadiness() -> HTTPResponse {
        // In a fuller implementation, check dependencies; for now return ready
        let json = try? JSONEncoder().encode(["status": "ready"]) 
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
        let gw = await GatewayRequestMetrics.shared.snapshot()
        for (k, v) in gw { metrics[k] = v }
        let cb = await breaker.metrics()
        for (k, v) in cb { metrics[k] = v }
        // RoleGuard metrics
        let rg = await RoleGuardMetrics.shared.snapshot()
        for (k, v) in rg { metrics[k] = v }
        if let json = try? JSONEncoder().encode(metrics) {
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
        }
        return HTTPResponse(status: 500)
    }

    private func listRoleGuardRules() async -> HTTPResponse {
        guard let store = roleGuardStore else { return HTTPResponse(status: 404) }
        let rules = await store.rules
        if let data = try? JSONEncoder().encode(rules) {
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        return HTTPResponse(status: 500)
    }

    private func reloadRoleGuardRules() async -> HTTPResponse {
        guard let store = roleGuardStore else { return HTTPResponse(status: 404) }
        let ok = await store.reload()
        if ok {
            let count = (await store.rules).count
            Task { await RoleGuardMetrics.shared.recordReload(ruleCount: count) }
        }
        return HTTPResponse(status: ok ? 204 : 304)
    }

    public func issueAuthToken(_ request: HTTPRequest) async -> HTTPResponse {
        do {
            let creds = try JSONDecoder().decode(CredentialRequest.self, from: request.body)
            let store = CredentialStore()
            guard store.validate(clientId: creds.clientId, clientSecret: creds.clientSecret) else {
                let json = try JSONEncoder().encode(ErrorResponse(error: "invalid credentials"))
                return HTTPResponse(status: 401, headers: ["Content-Type": "application/json"], body: json)
            }
            let expiry = Date().addingTimeInterval(3600)
            let formatter = ISO8601DateFormatter()
            let expires = formatter.string(from: expiry)
            let role = store.role(forClientId: creds.clientId)
            guard let token = try? store.signJWT(subject: creds.clientId, expiresAt: expiry, role: role) else {
                return HTTPResponse(status: 500)
            }
            let json = try JSONEncoder().encode(TokenResponse(token: token, expiresAt: expires))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
        } catch {
            return HTTPResponse(status: 400)
        }
    }

    public func certificateInfo() -> HTTPResponse {
        struct CertificateInfo: Codable { let notAfter: String; let issuer: String }
        guard let path = certificatePath else { return HTTPResponse(status: 500) }
        guard FileManager.default.fileExists(atPath: path) else { return HTTPResponse(status: 404) }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let cert: X509.Certificate
            if let pem = String(data: data, encoding: .utf8), pem.contains("-----BEGIN") {
                cert = try X509.Certificate(pemEncoded: pem)
            } else {
                cert = try X509.Certificate(derEncoded: [UInt8](data))
            }
            let formatter = ISO8601DateFormatter()
            let info = CertificateInfo(
                notAfter: formatter.string(from: cert.notValidAfter),
                issuer: cert.issuer.description
            )
            if let json = try? JSONEncoder().encode(info) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            }
            return HTTPResponse(status: 500)
        } catch {
            return HTTPResponse(status: 500)
        }
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
        guard let manager = zoneManager else { return self.error(500, message: "zone manager unavailable") }
        do {
            let req = try JSONDecoder().decode(ZoneCreateRequest.self, from: request.body)
            let zone = try await manager.createZone(name: req.name)
            let json = try JSONEncoder().encode(zone)
            return HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)
        } catch {
            return self.error(400, message: "invalid zone data")
        }
    }

    public func deleteZone(_ zoneId: String) async -> HTTPResponse {
        guard let manager = zoneManager else { return self.error(500, message: "zone manager unavailable") }
        guard let id = UUID(uuidString: zoneId) else { return self.error(404, message: "zone not found") }
        if let success = try? await manager.deleteZone(id: id), success {
            return HTTPResponse(status: 204)
        }
        return self.error(404, message: "zone not found")
    }

    public func listRecords(_ zoneId: String) async -> HTTPResponse {
        guard let manager = zoneManager else { return self.error(500, message: "zone manager unavailable") }
        guard let id = UUID(uuidString: zoneId) else { return self.error(404, message: "zone not found") }
        if let recs = await manager.listRecords(zoneId: id) {
            if let json = try? JSONEncoder().encode(RecordsResponse(records: recs)) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            }
            return self.error(500, message: "failed to encode records")
        }
        return self.error(404, message: "zone not found")
    }

    public func createRecord(_ zoneId: String, request: HTTPRequest) async -> HTTPResponse {
        guard let manager = zoneManager else { return self.error(500, message: "zone manager unavailable") }
        guard let id = UUID(uuidString: zoneId) else { return self.error(404, message: "zone not found") }
        do {
            let req = try JSONDecoder().decode(RecordRequest.self, from: request.body)
            if let record = try await manager.createRecord(zoneId: id, name: req.name, type: req.type.rawValue, value: req.value),
               let json = try? JSONEncoder().encode(record) {
                return HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)
            }
            return self.error(404, message: "zone not found")
        } catch {
            return self.error(400, message: "invalid record data")
        }
    }

    public func updateRecord(_ zoneId: String, recordId: String, request: HTTPRequest) async -> HTTPResponse {
        guard let manager = zoneManager else { return self.error(500, message: "zone manager unavailable") }
        guard let zid = UUID(uuidString: zoneId), let rid = UUID(uuidString: recordId) else {
            return self.error(404, message: "record not found")
        }
        do {
            let req = try JSONDecoder().decode(RecordRequest.self, from: request.body)
            if let record = try await manager.updateRecord(zoneId: zid, recordId: rid, name: req.name, type: req.type.rawValue, value: req.value),
               let json = try? JSONEncoder().encode(record) {
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
            }
            return self.error(404, message: "record not found")
        } catch {
            return self.error(400, message: "invalid record data")
        }
    }

    public func deleteRecord(_ zoneId: String, recordId: String) async -> HTTPResponse {
        guard let manager = zoneManager else { return self.error(500, message: "zone manager unavailable") }
        guard let zid = UUID(uuidString: zoneId), let rid = UUID(uuidString: recordId) else {
            return self.error(404, message: "record not found")
        }
        if let success = try? await manager.deleteRecord(zoneId: zid, recordId: rid), success {
            return HTTPResponse(status: 204)
        }
        return self.error(404, message: "record not found")
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
        roleGuardReloader?.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

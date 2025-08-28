import Foundation
import TypesensePersistence
import Dispatch
#if os(Linux)
import Glibc
#else
import Darwin
#endif

// MARK: Models (per openapi/v1/bootstrap.yml)
struct InitIn: Codable { let corpusId: String }
struct InitOut: Codable { let message: String }
struct BaselineIn: Codable { let corpusId: String; let baselineId: String; let content: String }
struct RoleInitRequest: Codable { let corpusId: String }
struct RoleDefaults: Codable {
    let drift: String
    let semantic_arc: String
    let patterns: String
    let history: String
    let view_creator: String
}

// MARK: HTTP primitives
struct HTTPRequest { let method: String; let path: String; let body: Data }
struct HTTPResponse { let status: Int; let headers: [String:String]; let body: Data }

final class BootstrapRouter: @unchecked Sendable {
    let persistence: TypesensePersistenceService

    init(persistence: TypesensePersistenceService) { self.persistence = persistence }

    private func defaultRoles() -> RoleDefaults {
        RoleDefaults(
            drift: "You are Drift, FountainAI’s baseline-drift detective. Compare a new baseline snapshot against prior versions to detect narrative or thematic drift and report the most significant changes.",
            semantic_arc: "You are Semantic Arc, tasked with tracing the corpus’s overarching narrative arc. Review the corpus history and synthesize a high-level storyline that highlights major turning points and transitions.",
            patterns: "You are Patterns, a spotter of recurring motifs, themes, or rhetorical structures. Inspect the corpus and list the strongest patterns you find.",
            history: "You are History, the curator of past reflections and events. Maintain a chronological log showing how the corpus has grown and changed, focusing on context useful for future analysis.",
            view_creator: "You are View Creator, responsible for assembling human-friendly views of the corpus and analyses. Produce a simple markdown or tabular view to help a human browse the information."
        )
    }

    func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        let pathOnly = request.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? request.path
        switch (request.method, pathOnly) {
        case ("GET", "/metrics"):
            let uptime = Int(ProcessInfo.processInfo.systemUptime)
            let body = Data("bootstrap_uptime_seconds \(uptime)\n".utf8)
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)
        case ("POST", "/bootstrap/corpus/init"):
            guard let input = try? JSONDecoder().decode(InitIn.self, from: request.body) else {
                return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
            }
            let resp = try await persistence.createCorpus(.init(corpusId: input.corpusId))
            // Seed roles
            let roles = defaultRoles()
            let roleDocs: [Role] = [
                .init(corpusId: input.corpusId, name: "drift", prompt: roles.drift),
                .init(corpusId: input.corpusId, name: "semantic_arc", prompt: roles.semantic_arc),
                .init(corpusId: input.corpusId, name: "patterns", prompt: roles.patterns),
                .init(corpusId: input.corpusId, name: "history", prompt: roles.history),
                .init(corpusId: input.corpusId, name: "view_creator", prompt: roles.view_creator)
            ]
            _ = try await persistence.seedDefaultRoles(corpusId: input.corpusId, defaults: roleDocs)
            let out = InitOut(message: "corpus \(resp.corpusId) initialized and roles seeded")
            let data = try JSONEncoder().encode(out)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("POST", "/bootstrap/roles/seed"), ("POST", "/bootstrap/roles"):
            guard let input = try? JSONDecoder().decode(RoleInitRequest.self, from: request.body) else {
                return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
            }
            let roles = defaultRoles()
            let roleDocs: [Role] = [
                .init(corpusId: input.corpusId, name: "drift", prompt: roles.drift),
                .init(corpusId: input.corpusId, name: "semantic_arc", prompt: roles.semantic_arc),
                .init(corpusId: input.corpusId, name: "patterns", prompt: roles.patterns),
                .init(corpusId: input.corpusId, name: "history", prompt: roles.history),
                .init(corpusId: input.corpusId, name: "view_creator", prompt: roles.view_creator)
            ]
            _ = try await persistence.seedDefaultRoles(corpusId: input.corpusId, defaults: roleDocs)
            let data = try JSONEncoder().encode(roles)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("POST", "/bootstrap/baseline"):
            guard let input = try? JSONDecoder().decode(BaselineIn.self, from: request.body) else {
                return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
            }
            _ = try await persistence.addBaseline(.init(corpusId: input.corpusId, baselineId: input.baselineId, content: input.content))
            // Fire-and-forget simulated drift/patterns persistence
            Task.detached { [persistence] in
                _ = try? await persistence.addDrift(.init(corpusId: input.corpusId, driftId: "\(input.baselineId)-drift", content: "auto-generated drift"))
                _ = try? await persistence.addPatterns(.init(corpusId: input.corpusId, patternsId: "\(input.baselineId)-patterns", content: "auto-generated patterns"))
            }
            let data = try JSONSerialization.data(withJSONObject: [:])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        default:
            return HTTPResponse(status: 404, headers: [:], body: Data())
        }
    }
}

final class SimpleHTTPRuntime: @unchecked Sendable {
    enum RuntimeError: Error { case socket, bind, listen }
    let router: BootstrapRouter
    let port: Int32
    private var serverFD: Int32 = -1

    init(router: BootstrapRouter, port: Int32 = 8082) { self.router = router; self.port = port }

    func start() throws {
        #if os(Linux)
        serverFD = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
        #else
        serverFD = socket(AF_INET, SOCK_STREAM, 0)
        #endif
        guard serverFD >= 0 else { throw RuntimeError.socket }
        var opt: Int32 = 1
        setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(MemoryLayout.size(ofValue: opt)))
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(UInt16(port).bigEndian)
        addr.sin_addr = in_addr(s_addr: in_addr_t(0))
        let bindResult = withUnsafePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in bind(serverFD, ptr, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        guard bindResult >= 0 else { throw RuntimeError.bind }
        guard listen(serverFD, 16) >= 0 else { throw RuntimeError.listen }
        DispatchQueue.global().async { [weak self] in self?.acceptLoop() }
    }

    private func acceptLoop() {
        while true {
            var addr = sockaddr()
            var len: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)
            let fd = accept(serverFD, &addr, &len)
            if fd >= 0 { DispatchQueue.global().async { self.handle(fd: fd) } }
        }
    }

    private func handle(fd: Int32) {
        var buffer = [UInt8](repeating: 0, count: 4096)
        let n = read(fd, &buffer, buffer.count)
        guard n > 0 else { close(fd); return }
        let data = Data(buffer[0..<n])
        guard let request = parseRequest(data) else { close(fd); return }
        Task {
            let resp = try await router.route(request)
            let respData = serialize(resp)
            respData.withUnsafeBytes { _ = write(fd, $0.baseAddress!, respData.count) }
            close(fd)
        }
    }

    private func parseRequest(_ data: Data) -> HTTPRequest? {
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        let parts = string.components(separatedBy: "\r\n\r\n")
        let headerLines = parts[0].split(separator: "\r\n")
        guard let requestLine = headerLines.first else { return nil }
        let tokens = requestLine.split(separator: " ")
        guard tokens.count >= 2 else { return nil }
        let method = String(tokens[0])
        let path = String(tokens[1])
        return HTTPRequest(method: method, path: path, body: parts.count>1 ? Data(parts[1].utf8) : Data())
    }

    private func serialize(_ resp: HTTPResponse) -> Data {
        var text = "HTTP/1.1 \(resp.status)\r\n"
        text += "Content-Length: \(resp.body.count)\r\n"
        for (k,v) in resp.headers { text += "\(k): \(v)\r\n" }
        text += "\r\n"
        var data = Data(text.utf8)
        data.append(resp.body)
        return data
    }
}

// Bootstrap runtime
do {
    let svc: TypesensePersistenceService
    if let url = ProcessInfo.processInfo.environment["TYPESENSE_URL"] ?? ProcessInfo.processInfo.environment["TYPESENSE_URLS"],
       let apiKey = ProcessInfo.processInfo.environment["TYPESENSE_API_KEY"], !apiKey.isEmpty {
        let urls = url.contains(",") ? url.split(separator: ",").map(String.init) : [url]
        #if canImport(Typesense)
        let client = RealTypesenseClient(nodes: urls, apiKey: apiKey, debug: false)
        svc = TypesensePersistenceService(client: client)
        #else
        svc = TypesensePersistenceService(client: MockTypesenseClient())
        #endif
    } else {
        svc = TypesensePersistenceService(client: MockTypesenseClient())
    }
    Task { await svc.ensureCollections() }
    let router = BootstrapRouter(persistence: svc)
    let runtime = SimpleHTTPRuntime(router: router, port: 8082)
    try runtime.start()
    print("bootstrap listening on :8082")
    dispatchMain()
} catch {
    print("Failed to start bootstrap: \(error)")
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


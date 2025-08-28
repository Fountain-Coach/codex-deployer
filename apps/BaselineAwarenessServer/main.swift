import Foundation
import TypesensePersistence
import Dispatch
#if os(Linux)
import Glibc
#else
import Darwin
#endif

// MARK: Models (per openapi/v1/baseline-awareness.yml)
struct InitIn: Codable { let corpusId: String }
struct InitOut: Codable { let message: String }
struct BaselineRequest: Codable { let corpusId: String; let baselineId: String; let content: String }
struct DriftRequest: Codable { let corpusId: String; let driftId: String; let content: String }
struct PatternsRequest: Codable { let corpusId: String; let patternsId: String; let content: String }
struct ReflectionRequest: Codable { let corpusId: String; let reflectionId: String; let question: String; let content: String }
struct ReflectionSummaryResponse: Codable { let message: String }
struct HistorySummaryResponse: Codable { let summary: String }

// MARK: HTTP primitives
struct HTTPRequest { let method: String; let path: String; let body: Data }
struct HTTPResponse { let status: Int; let headers: [String:String]; let body: Data }

final class AwarenessRouter: @unchecked Sendable {
    let persistence: TypesensePersistenceService

    init(persistence: TypesensePersistenceService) { self.persistence = persistence }

    func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        let pathOnly = request.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? request.path
        switch (request.method, pathOnly) {
        case ("GET", "/health"):
            let data = try JSONSerialization.data(withJSONObject: ["status": "ok"]) 
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        case ("GET", "/metrics"):
            let uptime = Int(ProcessInfo.processInfo.systemUptime)
            let body = Data("awareness_uptime_seconds \(uptime)\n".utf8)
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)
        case ("POST", "/corpus/init"):
            if let input = try? JSONDecoder().decode(InitIn.self, from: request.body) {
                let resp = try await persistence.createCorpus(.init(corpusId: input.corpusId))
                let out = InitOut(message: "corpus \(resp.corpusId) created")
                let data = try JSONEncoder().encode(out)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/baseline"):
            if let input = try? JSONDecoder().decode(BaselineRequest.self, from: request.body) {
                _ = try await persistence.addBaseline(.init(corpusId: input.corpusId, baselineId: input.baselineId, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/drift"):
            if let input = try? JSONDecoder().decode(DriftRequest.self, from: request.body) {
                _ = try await persistence.addDrift(.init(corpusId: input.corpusId, driftId: input.driftId, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/patterns"):
            if let input = try? JSONDecoder().decode(PatternsRequest.self, from: request.body) {
                _ = try await persistence.addPatterns(.init(corpusId: input.corpusId, patternsId: input.patternsId, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        case ("POST", "/corpus/reflections"):
            if let input = try? JSONDecoder().decode(ReflectionRequest.self, from: request.body) {
                _ = try await persistence.addReflection(.init(corpusId: input.corpusId, reflectionId: input.reflectionId, question: input.question, content: input.content))
                let data = try JSONSerialization.data(withJSONObject: ["message": "ok"]) 
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            }
            return HTTPResponse(status: 422, headers: ["Content-Type": "application/json"], body: Data())
        default:
            break
        }
        // Parameterized routes
        let segments = pathOnly.split(separator: "/").map(String.init)
        if request.method == "GET" && segments.count == 3 && segments[0] == "corpus" && segments[1] == "reflections" {
            let corpusId = segments[2]
            let (total, _) = try await persistence.listReflections(corpusId: corpusId)
            let data = try JSONEncoder().encode(ReflectionSummaryResponse(message: "\(total) reflections"))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && segments.count == 3 && segments[0] == "corpus" && segments[1] == "history" {
            let corpusId = segments[2]
            // naive summary across stored entities
            let (bCount, _) = try await persistence.listBaselines(corpusId: corpusId)
            let (rCount, _) = try await persistence.listReflections(corpusId: corpusId)
            let summary = "baselines=\(bCount), reflections=\(rCount)"
            let data = try JSONEncoder().encode(HistorySummaryResponse(summary: summary))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && segments.count == 3 && segments[0] == "corpus" && segments[1] == "summary" {
            let corpusId = segments[2]
            // reuse same summary for now
            let (bCount, _) = try await persistence.listBaselines(corpusId: corpusId)
            let (rCount, _) = try await persistence.listReflections(corpusId: corpusId)
            let summary = "summary for \(corpusId): baselines=\(bCount), reflections=\(rCount)"
            let data = try JSONEncoder().encode(HistorySummaryResponse(summary: summary))
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && pathOnly == "/corpus/history" {
            let data = try JSONSerialization.data(withJSONObject: ["events": []])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && pathOnly == "/corpus/semantic-arc" {
            let data = try JSONSerialization.data(withJSONObject: ["arc": []])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        if request.method == "GET" && pathOnly == "/corpus/history/stream" {
            let data = try JSONSerialization.data(withJSONObject: [:])
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
        }
        return HTTPResponse(status: 404, headers: [:], body: Data())
    }
}

final class SimpleHTTPRuntime: @unchecked Sendable {
    enum RuntimeError: Error { case socket, bind, listen }
    let router: AwarenessRouter
    let port: Int32
    private var serverFD: Int32 = -1

    init(router: AwarenessRouter, port: Int32 = 8081) { self.router = router; self.port = port }

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
    let router = AwarenessRouter(persistence: svc)
    let runtime = SimpleHTTPRuntime(router: router, port: 8081)
    try runtime.start()
    print("baseline-awareness listening on :8081")
    dispatchMain()
} catch {
    print("Failed to start baseline-awareness: \(error)")
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


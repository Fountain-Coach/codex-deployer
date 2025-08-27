import Foundation
import Dispatch
import FountainCodex
import SemanticBrowser

func buildService() -> SemanticMemoryService {
    let env = ProcessInfo.processInfo.environment
    let urls = env["SB_TYPESENSE_URLS"].map { $0.split(separator: ",").map(String.init) }
        ?? env["SB_TYPESENSE_URL"].map { [$0] }
        ?? env["TYPESENSE_URLS"].map { $0.split(separator: ",").map(String.init) }
        ?? env["TYPESENSE_URL"].map { [$0] }
    let apiKey = env["SB_TYPESENSE_API_KEY"] ?? env["TYPESENSE_API_KEY"]
    #if canImport(Typesense)
    if let urls, let apiKey, !urls.isEmpty, !apiKey.isEmpty {
        let backend = TypesenseSemanticBackend(nodes: urls, apiKey: apiKey, debug: false)
        return SemanticMemoryService(backend: backend)
    }
    #endif
    return SemanticMemoryService()
}

let service = buildService()
Task { await service.seed(pages: [PageDoc(id: "p1", url: "https://example.com/page", host: "example.com", title: "Example")]) }

let env = ProcessInfo.processInfo.environment
let engine: BrowserEngine = {
    if let ws = env["SB_CDP_URL"], let u = URL(string: ws) { return CDPBrowserEngine(wsURL: u) }
    if let bin = env["SB_BROWSER_CLI"] { return ShellBrowserEngine(binary: bin, args: (env["SB_BROWSER_ARGS"] ?? "").split(separator: " ").map(String.init)) }
    return URLFetchBrowserEngine()
}()
let apiKey = env["SB_API_KEY"] ?? env["SEM_BROWSER_API_KEY"]
let limiter = SimpleRateLimiter()
let limit = Int(env["SB_RATE_LIMIT"] ?? env["SEM_RATE_LIMIT"] ?? "60") ?? 60
let requireKey = (env["SB_REQUIRE_API_KEY"] ?? "true").lowercased() != "false"
let maxBody = max(Int(env["SB_REQ_BODY_MAX_BYTES"] ?? "1000000") ?? 1_000_000, 1024)
let reqTimeout = max(Int(env["SB_REQ_TIMEOUT_MS"] ?? "15000") ?? 15_000, 1000)
let metrics = SimpleMetrics()
let kernel = makeSemanticKernel(service: service, engine: engine, apiKey: apiKey, limiter: limiter, limitPerMinute: limit, requireAPIKey: requireKey, reqBodyMaxBytes: maxBody, reqTimeoutMs: reqTimeout, metrics: metrics)
let server = NIOHTTPServer(kernel: kernel)
Task { _ = try? await server.start(port: 8006); print("semantic-browser listening on 8006") }
dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

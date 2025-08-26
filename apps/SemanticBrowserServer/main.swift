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

let kernel = makeSemanticKernel(service: service)
let server = NIOHTTPServer(kernel: kernel)
Task { _ = try? await server.start(port: 8006); print("semantic-browser listening on 8006") }
dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

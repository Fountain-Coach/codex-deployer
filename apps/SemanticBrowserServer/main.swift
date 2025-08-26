import Foundation
import Dispatch
import FountainCodex
import SemanticBrowser

let service = SemanticMemoryService()
Task { await service.seed(pages: [PageDoc(id: "p1", url: "https://example.com/page", host: "example.com", title: "Example")]) }

let kernel = makeSemanticKernel(service: service)
let server = NIOHTTPServer(kernel: kernel)
Task { _ = try? await server.start(port: 8006); print("semantic-browser listening on 8006") }
dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

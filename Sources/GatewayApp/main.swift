import Foundation
import Dispatch
import PublishingFrontend

let publishingConfig = try? loadPublishingConfig()
let server = GatewayServer(plugins: [LoggingPlugin(), PublishingFrontendPlugin(rootPath: publishingConfig?.rootPath ?? "./Public")])
Task { @MainActor in
    try await server.start(port: 8080)
}

dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

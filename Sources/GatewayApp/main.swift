import Foundation
import Dispatch
import PublishingFrontend
import FountainCodex

/// Launches ``GatewayServer`` with the publishing plugin enabled.
/// The server stays running until the process is terminated.

let publishingConfig = try? loadPublishingConfig()
if publishingConfig == nil {
    FileHandle.standardError.write(Data("[gateway] Warning: failed to load Configuration/publishing.yml; using defaults for static content.\n".utf8))
}

let server = GatewayServer(plugins: [LoggingPlugin(), PublishingFrontendPlugin(rootPath: publishingConfig?.rootPath ?? "./Public")])
Task { @MainActor in
    try await server.start(port: 8080)
}

if CommandLine.arguments.contains("--dns") {
    Task {
        let zoneURL = URL(fileURLWithPath: "Configuration/zones.yml")
        if let manager = try? ZoneManager(fileURL: zoneURL) {
            let dns = await DNSServer(zoneManager: manager)
            try? await dns.start(udpPort: 1053)
        } else {
            FileHandle.standardError.write(Data("[gateway] Warning: failed to initialize ZoneManager\n".utf8))
        }
    }
}

dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

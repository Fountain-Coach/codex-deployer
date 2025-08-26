import Foundation
import Dispatch
import PublishingFrontend
import FountainCodex
import LLMGatewayPlugin
import AuthGatewayPlugin

/// Launches ``GatewayServer`` with the publishing plugin enabled.
/// The server stays running until the process is terminated.

let publishingConfig = try? loadPublishingConfig()
if publishingConfig == nil {
    FileHandle.standardError.write(Data("[gateway] Warning: failed to load Configuration/publishing.yml; using defaults for static content.\n".utf8))
}

let gatewayConfig = try? loadGatewayConfig()
if gatewayConfig == nil {
    FileHandle.standardError.write(Data("[gateway] Warning: failed to load Configuration/gateway.yml; using defaults for rate limiting.\n".utf8))
}
let rateLimiter = RateLimiterPlugin(defaultLimit: gatewayConfig?.rateLimitPerMinute ?? 60)
let cotLogPath = ProcessInfo.processInfo.environment["COT_LOG_PATH"].map { URL(fileURLWithPath: $0) }
let llmPlugin = LLMGatewayPlugin(cotLogURL: cotLogPath)
let authPlugin = AuthGatewayPlugin()
let sentinel = SecuritySentinelPlugin()
let server = GatewayServer(plugins: [authPlugin, llmPlugin, sentinel, CoTLogger(sentinel: sentinel), rateLimiter, LoggingPlugin(), PublishingFrontendPlugin(rootPath: publishingConfig?.rootPath ?? "./Public")], rateLimiter: rateLimiter)
Task { @MainActor in
    try await server.start(port: 8080)
}

if CommandLine.arguments.contains("--dns") {
    Task {
        let zoneURL = URL(fileURLWithPath: "Configuration/zones.yml")
        if let manager = try? ZoneManager(fileURL: zoneURL) {
            let dns = await DNSServer(zoneManager: manager)
            do {
                try await dns.start(udpPort: 1053)
            } catch {
                FileHandle.standardError.write(Data("[gateway] Warning: DNS failed to start on port 1053: \(error)\n".utf8))
            }
        } else {
            FileHandle.standardError.write(Data("[gateway] Warning: failed to initialize ZoneManager\n".utf8))
        }
    }
}

dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

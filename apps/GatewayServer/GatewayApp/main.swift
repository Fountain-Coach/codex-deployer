import Foundation
import Dispatch
import PublishingFrontend
import FountainRuntime
import LLMGatewayPlugin
import AuthGatewayPlugin
import RateLimiterGatewayPlugin
// Role guard plugin in this target
// Loaded from config if present

let publishingConfig = try? loadPublishingConfig()
if publishingConfig == nil {
    FileHandle.standardError.write(Data("[gateway] Warning: failed to load Configuration/publishing.yml; using defaults for static content.\n".utf8))
}

let gatewayConfig = try? loadGatewayConfig()
if gatewayConfig == nil {
    FileHandle.standardError.write(Data("[gateway] Warning: failed to load Configuration/gateway.yml; using defaults for rate limiting.\n".utf8))
}
let rateLimiter = RateLimiterGatewayPlugin(defaultLimit: gatewayConfig?.rateLimitPerMinute ?? 60)
let cotLogPath = ProcessInfo.processInfo.environment["COT_LOG_PATH"].map { URL(fileURLWithPath: $0) }
let llmPlugin = LLMGatewayPlugin(cotLogURL: cotLogPath)
let authPlugin = AuthGatewayPlugin()
let routesFile = URL(fileURLWithPath: "Configuration/routes.json")
var plugins: [any GatewayPlugin] = []
let rgURL = roleGuardConfigURL()
let roleRules = loadRoleGuardRules(from: rgURL)
let roleGuardStore = RoleGuardStore(initialRules: roleRules, configURL: rgURL)
// Choose validator based on environment (JWKS for HS256-oct if provided; otherwise env secret)
if let jwksURL = ProcessInfo.processInfo.environment["GATEWAY_JWKS_URL"], let provider = JWKSKeyProvider(jwksURL: jwksURL) {
    plugins.append(RoleGuardPlugin(store: roleGuardStore, validator: HMACKeyValidator(keyProvider: provider)))
} else {
    plugins.append(RoleGuardPlugin(store: roleGuardStore, validator: HMACKeyValidator()))
}
plugins.append(contentsOf: [
    authPlugin as any GatewayPlugin,
    llmPlugin as any GatewayPlugin,
    CoTLogger() as any GatewayPlugin,
    rateLimiter as any GatewayPlugin,
    LoggingPlugin() as any GatewayPlugin,
    PublishingFrontendPlugin(rootPath: publishingConfig?.rootPath ?? "./Public") as any GatewayPlugin
])

let server = GatewayServer(plugins: plugins, zoneManager: nil, routeStoreURL: routesFile, certificatePath: nil, rateLimiter: rateLimiter, roleGuardStore: roleGuardStore)
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

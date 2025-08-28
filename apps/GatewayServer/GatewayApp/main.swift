import Foundation
import Dispatch
import PublishingFrontend
import FountainCodex
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
// Load RoleGuard rules from YAML if available
func loadRoleGuardRules() -> [String: String] {
    let env = ProcessInfo.processInfo.environment
    let path = env["ROLE_GUARD_PATH"].map(URL.init(fileURLWithPath:)) ?? URL(fileURLWithPath: "Configuration/roleguard.yml")
    guard FileManager.default.fileExists(atPath: path.path),
          let text = try? String(contentsOf: path, encoding: .utf8) else { return [:] }
    do {
        if let yaml = try Yams.load(yaml: text) as? [String: Any], let rules = yaml["rules"] as? [String: String] {
            return rules
        }
    } catch {
        FileHandle.standardError.write(Data("[gateway] Warning: failed to parse RoleGuard rules at \(path.path)\n".utf8))
    }
    return [:]
}

var plugins: [GatewayPlugin] = []
let roleRules = loadRoleGuardRules()
if !roleRules.isEmpty { plugins.append(RoleGuardPlugin(rules: roleRules)) }
plugins.append(contentsOf: [authPlugin, llmPlugin, CoTLogger(), rateLimiter, LoggingPlugin(), PublishingFrontendPlugin(rootPath: publishingConfig?.rootPath ?? "./Public")])

let server = GatewayServer(plugins: plugins, zoneManager: nil, routeStoreURL: routesFile, certificatePath: nil, rateLimiter: rateLimiter)
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

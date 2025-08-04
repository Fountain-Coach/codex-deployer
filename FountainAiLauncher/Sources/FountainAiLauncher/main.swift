import Foundation

/// Services launched by the supervisor at application start.
let services: [Service] = [
    Service(name: "Awareness Service", binaryPath: "/usr/local/bin/awareness-service", port: 8001, healthPath: "/metrics"),
    Service(name: "Bootstrap Service", binaryPath: "/usr/local/bin/bootstrap-service", port: 8002, healthPath: "/metrics"),
    Service(name: "Planner Service", binaryPath: "/usr/local/bin/planner-service", port: 8003, healthPath: "/metrics"),
    Service(name: "Function Caller", binaryPath: "/usr/local/bin/function-caller", port: 8004, healthPath: "/metrics"),
    Service(name: "Persistence Service", binaryPath: "/usr/local/bin/persistence-service", port: 8005, healthPath: "/metrics"),
    Service(name: "LLM Gateway", binaryPath: "/usr/local/bin/llm-gateway", port: 8006, healthPath: "/metrics"),
    Service(name: "Gateway", binaryPath: "/usr/local/bin/fountain-gateway", port: 8010, healthPath: "/metrics"),
    Service(name: "Publishing Frontend", binaryPath: "/usr/local/bin/publishing-frontend", port: 8085, healthPath: "/metrics"),
    Service(name: "Typesense Proxy", binaryPath: "/usr/local/bin/typesense-proxy", port: 8100, healthPath: "/metrics")
]

let supervisor = Supervisor()

do {
    try supervisor.start(services: services)
    dispatchMain()
} catch {
    let message = "Failed to launch services: \(error)\n"
    if let data = message.data(using: .utf8) {
        FileHandle.standardError.write(data)
    }
    exit(1)
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

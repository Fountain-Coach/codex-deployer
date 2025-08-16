import Foundation

// Load service descriptors from bundled manifest.
let services: [Service]
if let url = Bundle.module.url(forResource: "services", withExtension: "json") {
    do {
        let data = try Data(contentsOf: url)
        services = try JSONDecoder().decode([Service].self, from: data)
    } catch {
        let message = "Failed to parse services.json: \(error)\n"
        FileHandle.standardError.write(Data(message.utf8))
        exit(1)
    }
} else {
    FileHandle.standardError.write(Data("services.json not found\n".utf8))
    exit(1)
}

let supervisor = Supervisor()
let monitor = HealthMonitor(supervisor: supervisor)

do {
    try supervisor.start(services: services)
    monitor.startMonitoring(services: services)
    dispatchMain()
} catch {
    let message = "Failed to launch services: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(1)
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

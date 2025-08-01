import Foundation

/// Manages child service processes and keeps them alive.
public final class Supervisor {
    private var processes: [String: Process] = [:]

    public init() {}

    @discardableResult
    /// Launches a single service process.
    /// - Parameter service: Descriptor for the binary to execute.
    /// - Returns: The running `Process` instance.
    public func start(service: Service) throws -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: service.binaryPath)
        process.arguments = service.arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        processes[service.name] = process
        print("Started \(service.name) (pid: \(process.processIdentifier))")
        return process
    }

    /// Starts a collection of services sequentially.
    public func start(services: [Service]) throws {
        for service in services {
            try start(service: service)
        }
    }

    /// Terminates all running services.
    public func terminateAll() {
        for (_, process) in processes {
            if process.isRunning {
                process.terminate()
            }
        }
        processes.removeAll()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

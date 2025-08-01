import Foundation

/// Manages child service processes and keeps them alive.
public final class Supervisor {
    /// Running child processes keyed by service name.
    private var processes: [String: Process] = [:]

    /// Creates a new empty supervisor.
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
    /// - Parameter services: Array of ``Service`` descriptors.
    public func start(services: [Service]) throws {
        for service in services {
            try start(service: service)
        }
    }

    /// Terminates all running services and clears internal state.
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

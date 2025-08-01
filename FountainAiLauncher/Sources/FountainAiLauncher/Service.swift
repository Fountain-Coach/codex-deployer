import Foundation

/// Describes an executable service managed by ``Supervisor``.
public struct Service {
    /// Human readable identifier used by ``Supervisor``.
    public let name: String
    /// Absolute path to the executable binary on disk.
    public let binaryPath: String
    /// Arguments passed to the process on launch.
    public let arguments: [String]
    /// Optional port used for health checks.
    public let port: Int?
    /// Optional HTTP path of the health check endpoint.
    public let healthPath: String?

    /// Creates a new service descriptor.
    /// - Parameters:
    ///   - name: Human readable identifier.
    ///   - binaryPath: Absolute path to the executable.
    ///   - arguments: Arguments passed on launch.
    ///   - port: Optional port for health checks.
    ///   - healthPath: Health check endpoint path.
    public init(name: String, binaryPath: String, arguments: [String] = [], port: Int? = nil, healthPath: String? = nil) {
        self.name = name
        self.binaryPath = binaryPath
        self.arguments = arguments
        self.port = port
        self.healthPath = healthPath
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

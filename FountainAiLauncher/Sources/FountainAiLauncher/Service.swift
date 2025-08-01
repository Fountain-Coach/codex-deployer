import Foundation

/// Describes an executable service managed by ``Supervisor``.
public struct Service {
    public let name: String
    public let binaryPath: String
    public let arguments: [String]
    public let port: Int?
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

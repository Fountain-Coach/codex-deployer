// Models for Sample API

/// Simple task model used in unit tests.
/// Represents an item with identifier and name.
public struct Todo: Codable, Equatable {
    /// Unique identifier for the task.
    public let id: Int
    /// Human-readable name for the task.
    public let name: String
}


// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

// Models for Sample API

/// Simple task model used in unit tests.
/// Represents an item with identifier and title.
public struct Todo: Codable, Equatable {
    /// Unique identifier for the task.
    public let id: Int
    /// Human-readable title for the task.
    public let name: String
}


// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

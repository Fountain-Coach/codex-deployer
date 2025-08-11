import Foundation

/// Type of entity that can be referenced in a specification.
public enum EntityType {
    case messageID
    case term
}

/// Represents a uniquely identifiable entity such as a message ID or glossary term.
public struct Entity {
    /// Name of the entity.
    public let name: String
    /// Classification of the entity.
    public let type: EntityType
    /// Human readable definition.
    public let definition: String

    /// Creates a new entity definition.
    public init(name: String, type: EntityType, definition: String) {
        self.name = name
        self.type = type
        self.definition = definition
    }
}

/// Section of normative text or table extracted from a document.
public struct NormativeSection {
    /// Identifier of the section.
    public let id: String
    /// Plain text content of the section.
    public let text: String
    /// Optional table content represented as rows and columns.
    public let table: [[String]]

    /// Creates a section with text and optional table rows.
    public init(id: String, text: String, table: [[String]] = []) {
        self.id = id
        self.text = text
        self.table = table
    }
}

/// Maintains a registry of entities, tracking duplicates and conflicting definitions.
public struct EntityRegistry {
    private var entities: [String: Entity] = [:]
    private var conflicts: [String: [Entity]] = [:]

    public init() {}

    /// Registers a new entity definition.
    /// When an entity with the same name but different definition exists,
    /// the definitions are recorded as a conflict.
    public mutating func register(_ entity: Entity) {
        if let existing = entities[entity.name] {
            if existing.definition != entity.definition || existing.type != entity.type {
                conflicts[entity.name, default: [existing]].append(entity)
            }
        } else {
            entities[entity.name] = entity
        }
    }

    /// Resolves an entity by name.
    public func resolve(_ name: String) -> Entity? {
        entities[name]
    }

    /// Returns conflicting definitions for a given entity name if present.
    public func conflicts(for name: String) -> [Entity]? {
        conflicts[name]
    }
}

/// Links entities to the sections where they are referenced.
public enum NormativeLinker {
    /// Performs a match between sections and entities.
    /// - Parameters:
    ///   - sections: Extracted normative sections from a document.
    ///   - entities: Known entities with definitions.
    /// - Returns: Array of linked sections enriched with matching entities.
    public static func link(sections: [NormativeSection], entities: [Entity]) -> [LinkedSection] {
        var results: [LinkedSection] = []
        for section in sections {
            var matches: [Entity] = []
            for entity in entities {
                if section.text.contains(entity.name) ||
                    section.tableJoined.contains(where: { $0.contains(entity.name) }) {
                    matches.append(entity)
                }
            }
            if !matches.isEmpty {
                results.append(LinkedSection(section: section, entities: matches))
            }
        }
        return results
    }
}

/// A section annotated with the entities it references.
public struct LinkedSection {
    /// Original section information.
    public let section: NormativeSection
    /// Entities found within the section.
    public let entities: [Entity]
}

private extension NormativeSection {
    /// Flattens table rows into a single array of cell strings for easy scanning.
    var tableJoined: [String] {
        table.flatMap { $0 }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

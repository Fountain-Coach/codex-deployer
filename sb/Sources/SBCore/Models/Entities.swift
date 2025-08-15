import Foundation

public struct Entity: Codable, Sendable {
    public enum EntityType: String, Codable, Sendable {
        case PERSON
        case ORG
        case LOC
        case PROD
        case EVENT
        case OTHER
    }

    public struct Mention: Codable, Sendable {
        public var block: String
        public var span: [Int]?

        public init(block: String, span: [Int]? = nil) {
            self.block = block
            self.span = span
        }
    }

    public var id: String
    public var name: String
    public var type: EntityType
    public var mentions: [Mention]

    public init(id: String, name: String, type: EntityType, mentions: [Mention]) {
        self.id = id
        self.name = name
        self.type = type
        self.mentions = mentions
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

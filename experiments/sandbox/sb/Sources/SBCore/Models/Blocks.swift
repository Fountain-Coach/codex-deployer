import Foundation

public struct Block: Codable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case heading
        case paragraph
        case code
        case caption
        case table
    }

    public var id: String
    public var kind: Kind
    public var level: Int?
    public var text: String
    public var span: [Int]?
    public var table: Table?

    public init(id: String, kind: Kind, level: Int? = nil, text: String, span: [Int]? = nil, table: Table? = nil) {
        self.id = id
        self.kind = kind
        self.level = level
        self.text = text
        self.span = span
        self.table = table
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

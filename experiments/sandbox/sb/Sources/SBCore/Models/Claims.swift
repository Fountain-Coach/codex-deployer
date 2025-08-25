import Foundation

public struct Claim: Codable, Sendable {
    public enum Stance: String, Codable, Sendable {
        case AUTHOR_ASSERTED
        case REPORTED
        case UNCERTAIN
    }

    public enum Hedge: String, Codable, Sendable {
        case LOW
        case MEDIUM
        case HIGH
    }

    public struct Evidence: Codable, Sendable {
        public var block: String
        public var span: [Int]?
        public var tableCell: [Int]?

        public init(block: String, span: [Int]? = nil, tableCell: [Int]? = nil) {
            self.block = block
            self.span = span
            self.tableCell = tableCell
        }
    }

    public var id: String
    public var text: String
    public var stance: Stance
    public var hedge: Hedge
    public var evidence: [Evidence]

    public init(id: String, text: String, stance: Stance = .AUTHOR_ASSERTED, hedge: Hedge = .MEDIUM, evidence: [Evidence]) {
        self.id = id
        self.text = text
        self.stance = stance
        self.hedge = hedge
        self.evidence = evidence
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

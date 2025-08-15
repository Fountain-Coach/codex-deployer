import Foundation

public struct Analysis: Codable, Sendable {
    public struct Envelope: Codable, Sendable {
        public struct Source: Codable, Sendable {
            public var uri: URL?
            public var fetchedAt: Date?
            public init(uri: URL? = nil, fetchedAt: Date? = nil) {
                self.uri = uri
                self.fetchedAt = fetchedAt
            }
        }
        public var id: String
        public var source: Source?
        public var contentType: String
        public var language: String
        public var bytes: Int?
        public var diagnostics: [String]?

        public init(id: String, source: Source? = nil, contentType: String, language: String, bytes: Int? = nil, diagnostics: [String]? = nil) {
            self.id = id
            self.source = source
            self.contentType = contentType
            self.language = language
            self.bytes = bytes
            self.diagnostics = diagnostics
        }
    }

    public struct Semantics: Codable, Sendable {
        public struct OutlineItem: Codable, Sendable {
            public var block: String
            public var level: Int?
            public init(block: String, level: Int? = nil) {
                self.block = block
                self.level = level
            }
        }
        public struct Relation: Codable, Sendable {
            public enum RelationType: String, Codable, Sendable {
                case SUPPORTS, CONTRADICTS, CITES, REFERS_TO
            }
            public var type: RelationType
            public var from: String
            public var to: String
            public init(type: RelationType, from: String, to: String) {
                self.type = type
                self.from = from
                self.to = to
            }
        }
        public var outline: [OutlineItem]?
        public var entities: [Entity]?
        public var claims: [Claim]?
        public var relations: [Relation]?

        public init(outline: [OutlineItem]? = nil, entities: [Entity]? = nil, claims: [Claim]? = nil, relations: [Relation]? = nil) {
            self.outline = outline
            self.entities = entities
            self.claims = claims
            self.relations = relations
        }
    }

    public struct Summaries: Codable, Sendable {
        public var abstract: String?
        public var keyPoints: [String]?
        public var tl_dr: String?
        public init(abstract: String? = nil, keyPoints: [String]? = nil, tl_dr: String? = nil) {
            self.abstract = abstract
            self.keyPoints = keyPoints
            self.tl_dr = tl_dr
        }
    }

    public struct Provenance: Codable, Sendable {
        public var pipeline: String?
        public var model: String?
        public init(pipeline: String? = nil, model: String? = nil) {
            self.pipeline = pipeline
            self.model = model
        }
    }

    public var envelope: Envelope
    public var blocks: [Block]
    public var semantics: Semantics?
    public var summaries: Summaries?
    public var provenance: Provenance?

    public init(envelope: Envelope, blocks: [Block], semantics: Semantics? = nil, summaries: Summaries? = nil, provenance: Provenance? = nil) {
        self.envelope = envelope
        self.blocks = blocks
        self.semantics = semantics
        self.summaries = summaries
        self.provenance = provenance
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

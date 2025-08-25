// Models for Semantic Browser & Dissector API

public struct Analysis: Codable {
    public let blocks: [Block]
    public let envelope: [String: String]
    public let provenance: [String: String]
    public let semantics: [String: String]
    public let summaries: [String: String]
}

public struct AnalyzeRequest: Codable {
    public let mode: DissectionMode
    public let snapshot: Snapshot
    public let snapshotRef: [String: String]
}

public struct Block: Codable {
    public let id: String
    public let kind: String
    public let level: Int
    public let span: [Int]
    public let table: Table
    public let text: String
}

public struct BrowseRequest: Codable {
    public let index: IndexOptions
    public let labels: [String]
    public let mode: DissectionMode
    public let storeArtifacts: Bool
    public let url: String
    public let wait: WaitPolicy
}

public struct BrowseResponse: Codable {
    public let analysis: Analysis
    public let index: IndexResult
    public let snapshot: Snapshot
}

public struct Claim: Codable {
    public let evidence: [[String: String]]
    public let hedge: String
    public let id: String
    public let stance: String
    public let text: String
}

public enum DissectionMode: String, Codable {
    case quick
    case standard
    case deep
}

public struct Entity: Codable {
    public let id: String
    public let mentions: [[String: String]]
    public let name: String
    public let type: String
}

public struct EntityDoc: Codable {
    public let id: String
    public let mentions: Int
    public let name: String
    public let pageCount: Int
    public let type: String
}

public struct Error: Codable {
    public let code: String
    public let details: [String: String]
    public let message: String
}

public struct IndexOptions: Codable {
    public let enabled: Bool
    public let entitiesCollection: String
    public let pagesCollection: String
    public let segmentsCollection: String
    public let tablesCollection: String
    public let typesense: [String: String]
}

public struct IndexRequest: Codable {
    public let analysis: Analysis
    public let options: IndexOptions
}

public struct IndexResult: Codable {
    public let entitiesUpserted: Int
    public let pagesUpserted: Int
    public let segmentsUpserted: Int
    public let tablesUpserted: Int
}

public struct PageDoc: Codable {
    public let contentType: String
    public let fetchedAt: Int
    public let host: String
    public let id: String
    public let labels: [String]
    public let lang: String
    public let status: Int
    public let textSize: Int
    public let title: String
    public let url: String
}

public struct SegmentDoc: Codable {
    public let entities: [String]
    public let id: String
    public let kind: String
    public let offsetEnd: Int
    public let offsetStart: Int
    public let pageId: String
    public let pathHint: String
    public let text: String
}

public struct Snapshot: Codable {
    public let diagnostics: [String]
    public let network: [String: String]
    public let page: [String: String]
    public let rendered: [String: String]
    public let snapshotId: String
}

public struct SnapshotRequest: Codable {
    public let storeArtifacts: Bool
    public let url: String
    public let wait: WaitPolicy
}

public struct SnapshotResponse: Codable {
    public let snapshot: Snapshot
}

public struct Table: Codable {
    public let caption: String
    public let columns: [String]
    public let rows: [[String]]
}

public struct WaitPolicy: Codable {
    public let maxWaitMs: Int
    public let networkIdleMs: Int
    public let selector: String
    public let strategy: String
}

public struct queryPagesResponse: Codable {
    public let items: [PageDoc]
    public let total: Int
}

public struct healthResponse: Codable {
    public let browserPool: [String: String]
    public let status: String
    public let version: String
}

public struct queryEntitiesResponse: Codable {
    public let items: [EntityDoc]
    public let total: Int
}

public typealias exportArtifactsResponse = [String: String]

public struct querySegmentsResponse: Codable {
    public let items: [SegmentDoc]
    public let total: Int
}


© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

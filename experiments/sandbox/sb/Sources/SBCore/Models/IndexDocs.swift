import Foundation

public struct PageDoc: Codable, Sendable {
    public var id: String?
    public var url: URL?
    public var host: String?
    public var status: Int?
    public var contentType: String?
    public var lang: String?
    public var title: String?
    public var textSize: Int?
    public var fetchedAt: Int?
    public var labels: [String]?

    public init(id: String? = nil, url: URL? = nil, host: String? = nil, status: Int? = nil, contentType: String? = nil, lang: String? = nil, title: String? = nil, textSize: Int? = nil, fetchedAt: Int? = nil, labels: [String]? = nil) {
        self.id = id
        self.url = url
        self.host = host
        self.status = status
        self.contentType = contentType
        self.lang = lang
        self.title = title
        self.textSize = textSize
        self.fetchedAt = fetchedAt
        self.labels = labels
    }
}

public struct SegmentDoc: Codable, Sendable {
    public var id: String?
    public var pageId: String?
    public var kind: String?
    public var text: String?
    public var pathHint: String?
    public var offsetStart: Int?
    public var offsetEnd: Int?
    public var entities: [String]?

    public init(id: String? = nil, pageId: String? = nil, kind: String? = nil, text: String? = nil, pathHint: String? = nil, offsetStart: Int? = nil, offsetEnd: Int? = nil, entities: [String]? = nil) {
        self.id = id
        self.pageId = pageId
        self.kind = kind
        self.text = text
        self.pathHint = pathHint
        self.offsetStart = offsetStart
        self.offsetEnd = offsetEnd
        self.entities = entities
    }
}

public struct EntityDoc: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var type: String?
    public var pageCount: Int?
    public var mentions: Int?

    public init(id: String? = nil, name: String? = nil, type: String? = nil, pageCount: Int? = nil, mentions: Int? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.pageCount = pageCount
        self.mentions = mentions
    }
}

public struct IndexResult: Codable, Sendable {
    public var pagesUpserted: Int?
    public var segmentsUpserted: Int?
    public var entitiesUpserted: Int?
    public var tablesUpserted: Int?

    public init(pagesUpserted: Int? = nil, segmentsUpserted: Int? = nil, entitiesUpserted: Int? = nil, tablesUpserted: Int? = nil) {
        self.pagesUpserted = pagesUpserted
        self.segmentsUpserted = segmentsUpserted
        self.entitiesUpserted = entitiesUpserted
        self.tablesUpserted = tablesUpserted
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

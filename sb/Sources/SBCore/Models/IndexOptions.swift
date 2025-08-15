import Foundation

public struct IndexOptions: Codable, Sendable {
    public struct Typesense: Codable, Sendable {
        public var url: URL?
        public var apiKey: String?
        public var timeoutMs: Int?

        public init(url: URL? = nil, apiKey: String? = nil, timeoutMs: Int? = nil) {
            self.url = url
            self.apiKey = apiKey
            self.timeoutMs = timeoutMs
        }
    }

    public var enabled: Bool?
    public var pagesCollection: String?
    public var segmentsCollection: String?
    public var entitiesCollection: String?
    public var tablesCollection: String?
    public var typesense: Typesense?

    public init(enabled: Bool? = nil,
                pagesCollection: String? = nil,
                segmentsCollection: String? = nil,
                entitiesCollection: String? = nil,
                tablesCollection: String? = nil,
                typesense: Typesense? = nil) {
        self.enabled = enabled
        self.pagesCollection = pagesCollection
        self.segmentsCollection = segmentsCollection
        self.entitiesCollection = entitiesCollection
        self.tablesCollection = tablesCollection
        self.typesense = typesense
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
